//
//  IRDataStore.m
//  IRFoundations
//
//  Created by Evadne Wu on 7/21/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <objc/runtime.h>
#import "IRDataStore.h"
#import "IRManagedObjectContext.h"
#import "IRLifetimeHelper.h"


NSString * const kIRDataStore_DefaultAutoUpdatedMOC = @"IRDataStore_DefaultAutoUpdatedMOC";

@interface IRDataStore ()

@property (nonatomic, readwrite, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readwrite, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation IRDataStore

@synthesize managedObjectModel, persistentStoreCoordinator;
@synthesize persistentStoreName;

+ (IRDataStore *) defaultStore {

	static dispatch_once_t predicate = 0; 
	static id returned = nil;
	
	dispatch_once(&predicate, ^ {
		returned = [[self alloc] init];
	});
	
	return returned;

}

- (IRDataStore *) init {

	self = [self initWithManagedObjectModel:nil];
	if (!self)
		return nil;
	
	return self;

}

- (NSManagedObjectModel *) defaultManagedObjectModel {

	[NSException raise:NSInternalInconsistencyException format:@"Subclasses shall provide a custom managed object model."];
	return nil;

}

- (NSURL *) defaultPersistentStoreURL {

	NSString *defaultFilename = [self.persistentStoreName stringByAppendingPathExtension:@"sqlite"];
	NSParameterAssert(defaultFilename);
	
	#if TARGET_OS_MAC
	
	NSString *usedAppName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
	if (!usedAppName)
		usedAppName = [[NSBundle mainBundle] bundleIdentifier];

	if (!usedAppName) {
		//	Could be in test cases
		usedAppName = [[NSBundle bundleForClass:(id)[self class]] bundleIdentifier];
	}
	
	NSParameterAssert(usedAppName);

	return [[(NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:usedAppName] URLByAppendingPathComponent:defaultFilename];
	
	#else
	
	return [(NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:defaultFilename];
	
	#endif

}

- (IRDataStore *) initWithManagedObjectModel:(NSManagedObjectModel *)model {

	self = [super init];
	if (!self)
		return nil;
	
	persistentStoreName = [[[NSBundle mainBundle] bundleIdentifier] copy];
	if (!persistentStoreName)
		persistentStoreName = [@"PersistentStore" copy];
	
	managedObjectModel = [model retain];

	return self;

}

- (NSManagedObjectModel *) managedObjectModel {

	if (managedObjectModel)
		return managedObjectModel;

	managedObjectModel = [[self defaultManagedObjectModel] retain];
	return managedObjectModel;

}

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

	if (persistentStoreCoordinator)
		return persistentStoreCoordinator;

	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
	NSURL *storeURL = [self defaultPersistentStoreURL];
	
	BOOL continuesTrying = YES;
	
	while (continuesTrying) {
	
		[[NSFileManager defaultManager] createDirectoryAtPath:[[storeURL path] stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
				
		NSError *persistentStoreAddingError = nil;
		NSPersistentStore *addedStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:[NSDictionary dictionaryWithObjectsAndKeys:
		
			(id)kCFBooleanTrue, NSMigratePersistentStoresAutomaticallyOption,
			(id)kCFBooleanTrue, NSInferMappingModelAutomaticallyOption,
		
		nil] error:&persistentStoreAddingError];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		
		if (!addedStore) {
		
			NSLog(@"Error adding persistent store: %@", persistentStoreAddingError);
				
			if ([fileManager fileExistsAtPath:[storeURL path]]) {
			
				[fileManager removeItemAtURL:storeURL error:nil];
				continuesTrying = YES;
		
			} else {
			
				continuesTrying = NO;
			
			}
			
		} else {
		
			continuesTrying = NO;
		
		};
	
	}
	
	//	At this point, things might be okay
	//	Let’s save to the file at least once
	
	NSParameterAssert([persistentStoreCoordinator.persistentStores count]);
	return persistentStoreCoordinator;

}

- (void) setPersistentStoreName:(NSString *)newPersistentStoreName {

	if (persistentStoreName == newPersistentStoreName)
		return;
	
	[persistentStoreName release];
	persistentStoreName = [newPersistentStoreName retain];

	self.persistentStoreCoordinator = nil;
	objc_setAssociatedObject(self, &kIRDataStore_DefaultAutoUpdatedMOC, nil, OBJC_ASSOCIATION_ASSIGN);
		
}

- (IRManagedObjectContext *) defaultAutoUpdatedMOC {

	__block IRManagedObjectContext *returnedContext = objc_getAssociatedObject(self, &kIRDataStore_DefaultAutoUpdatedMOC);
	
	if (!returnedContext) {
	
		returnedContext = (IRManagedObjectContext *)[self disposableMOC];
		[returnedContext irBeginMergingFromSavesAutomatically];
		[returnedContext irPerformOnDeallocation: ^ {
			[returnedContext irStopMergingFromSavesAutomatically];
		}];
		
		objc_setAssociatedObject(self, &kIRDataStore_DefaultAutoUpdatedMOC, returnedContext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	}
	
	return returnedContext;

}

- (IRManagedObjectContext *) disposableMOC {

	IRManagedObjectContext *returnedContext = [[[IRManagedObjectContext alloc] init] autorelease];
	[returnedContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
	[returnedContext setUndoManager:nil];
	
	return returnedContext;

}

- (void) dealloc {

	__block NSManagedObjectContext *autoUpdatedMOC = objc_getAssociatedObject(self, &kIRDataStore_DefaultAutoUpdatedMOC);
	if (autoUpdatedMOC) {
		@autoreleasepool {
			[[autoUpdatedMOC retain] autorelease];
			objc_setAssociatedObject(self, &kIRDataStore_DefaultAutoUpdatedMOC, nil, OBJC_ASSOCIATION_ASSIGN);
		}
	}
	
	[persistentStoreName release];
	[managedObjectModel release];
	[persistentStoreCoordinator release];

	[super dealloc];

}





NSString * IRDataStoreTimestamp () {

	return [NSString stringWithFormat:@"%d", time(NULL)];

}

NSString * IRDataStoreNonce () {

	NSString *uuid = nil;
	CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
	
	if (!theUUID)
		return nil;
	
	uuid = [(NSString *)CFUUIDCreateString(kCFAllocatorDefault, theUUID) autorelease];
	CFRelease(theUUID);
	
	return [NSString stringWithFormat:@"%@-%@", IRDataStoreTimestamp(), uuid];
	
}





- (NSString *) persistentFileURLBasePath {

	//	Here’s a fundamental assumption: app bundle won’t get moved when the app is running.
	//	If that fails, don’t cache the path.

	static NSString * path;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{

		path = [[(NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path] retain];
	
	});

	return path;

}

- (NSString *) relativePathWithBasePath:(NSString *)basePath filePath:(NSString *)filePath {

	if (![filePath hasPrefix:basePath])
		return filePath;
	
	return [filePath substringFromIndex:[basePath length]];
	
}

- (NSString *) absolutePathWithBasePath:(NSString *)basePath filePath:(NSString *)filePath {

	return [[basePath stringByAppendingPathComponent:filePath] stringByExpandingTildeInPath];

}

- (NSURL *) oneUsePersistentFileURL {

	return [NSURL fileURLWithPath:[[self persistentFileURLBasePath] stringByAppendingPathComponent:IRDataStoreNonce()]];

}

- (NSURL *) persistentFileURLForData:(NSData *)data {

	return [self persistentFileURLForData:data extension:nil];
	
}

- (NSURL *) persistentFileURLForData:(NSData *)data extension:(NSString *)fileExtension {

	NSURL *fileURL = [self oneUsePersistentFileURL];
	
	if (fileExtension)
		fileURL = [fileURL URLByAppendingPathExtension:fileExtension];
	
	[data writeToURL:fileURL atomically:NO];
	
	return fileURL;	

}

- (NSURL *) persistentFileURLForFileAtURL:(NSURL *)aURL {

	NSFileManager *fileManager = [NSFileManager defaultManager];
	
#ifndef NS_BLOCK_ASSERTIONS
{	
	BOOL isDirectoryURL = NO;
	NSAssert2(([fileManager fileExistsAtPath:[aURL path] isDirectory:&isDirectoryURL] && !isDirectoryURL), @"URL %@ must exist%@.", aURL, (isDirectoryURL ? @" and should not be a directory" : @""));
};
#endif
	
	NSURL *fileURL = [self oneUsePersistentFileURL];
	fileURL = [NSURL fileURLWithPath:[[fileURL path] stringByAppendingPathExtension:[[aURL path] pathExtension]]];
	
	NSError *error = nil;
	if ([fileManager createDirectoryAtPath:[[aURL path] stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error])
	if ([fileManager copyItemAtURL:aURL toURL:fileURL error:&error])
		return fileURL;
		
	NSLog(@"%s: Error copying from %@ to %@: %@", __PRETTY_FUNCTION__, aURL, fileURL, error);
	return nil;

}

- (NSURL *) persistentFileURLForFileAtPath:(NSString *)aPath {
	return [self persistentFileURLForFileAtURL:[NSURL fileURLWithPath:aPath]];
}

- (NSManagedObject *) updateObjectAtURI:(NSURL *)anObjectURI inContext:(NSManagedObjectContext *)aContext takingBlobFromTemporaryFile:(NSString *)aPath usingResourceType:(NSString *)utiType forKeyPath:(NSString *)fileKeyPath matchingURL:(NSURL *)anURL forKeyPath:(NSString *)urlKeyPath {

	NSCParameterAssert(anObjectURI);
	NSCParameterAssert(aPath);
	NSCParameterAssert(fileKeyPath);
	NSCParameterAssert(anURL);
	NSCParameterAssert(urlKeyPath);
		
	NSManagedObjectContext * const context = ((^ {
	
		if (aContext)
			return aContext;
		
		NSManagedObjectContext * const returnedContext = [self disposableMOC];
		returnedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
		return returnedContext;
	
	})());

	NSCParameterAssert(context);
	
	@try {
	
		NSManagedObject * const object = [context irManagedObjectForURI:anObjectURI];
		if ([self updateObject:object inContext:context takingBlobFromTemporaryFile:aPath usingResourceType:utiType forKeyPath:fileKeyPath matchingURL:anURL forKeyPath:urlKeyPath])
			return object;
		
	} @catch (NSException *e) {
	
		NSLog(@"%s: %@", __PRETTY_FUNCTION__, e);
	
	};
	
	return nil;

}

- (BOOL) updateObject:(NSManagedObject *)anObject inContext:(NSManagedObjectContext *)aContext takingBlobFromTemporaryFile:(NSString *)aPath usingResourceType:(NSString *)utiType forKeyPath:(NSString *)fileKeyPath matchingURL:(NSURL *)anURL forKeyPath:(NSString *)urlKeyPath {

	@try {
		[anObject primitiveValueForKey:[(NSPropertyDescription *)[[anObject.entity properties] lastObject] name]];
	} @catch (NSException *exception) {
		NSLog(@"Got access exception: %@", exception);
	}

	NSString *currentFilePath = [anObject valueForKey:fileKeyPath];
	if (currentFilePath || ![[anObject valueForKey:urlKeyPath] isEqualToString:[anURL absoluteString]]) {
		//	NSLog(@"Skipping double-writing");
		return NO;
	}
	
	NSURL *fileURL = [self persistentFileURLForFileAtURL:[NSURL fileURLWithPath:aPath]];
	if (!fileURL) {
		NSLog(@"%s: nil file URL", __PRETTY_FUNCTION__);
		return NO;
	}
	
	NSString *preferredExtension = utiType ? [NSMakeCollectable(UTTypeCopyPreferredTagWithClass((CFStringRef)utiType, kUTTagClassFilenameExtension)) autorelease] : nil;
	
	if (preferredExtension) {
		
		NSURL *newFileURL = [NSURL fileURLWithPath:[[[fileURL path] stringByDeletingPathExtension] stringByAppendingPathExtension:preferredExtension]];
		
		NSError *movingError = nil;
		BOOL didMove = [[NSFileManager defaultManager] moveItemAtURL:fileURL toURL:newFileURL error:&movingError];
		if (!didMove) {
			NSLog(@"Error moving: %@", movingError);
			return NO;
		}
			
		fileURL = newFileURL;
		
	}
	
	[anObject setValue:[fileURL path] forKey:fileKeyPath];
	
	return YES;

}

@end
