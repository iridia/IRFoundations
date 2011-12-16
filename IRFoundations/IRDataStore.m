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
	NSLog(@"making persistentStoreCoordinator using name %@", storeURL);
	
	BOOL continuesTrying = YES;
	
	while (continuesTrying) {
	
		[[NSFileManager defaultManager] createDirectoryAtPath:[[storeURL path] stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
				
		NSError *persistentStoreAddingError = nil;
		NSPersistentStore *addedStore = [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:[NSDictionary dictionaryWithObjectsAndKeys:
		
			(id)kCFBooleanTrue, NSMigratePersistentStoresAutomaticallyOption,
			(id)kCFBooleanTrue, NSInferMappingModelAutomaticallyOption,
		
		nil] error:&persistentStoreAddingError];
		
		if (!addedStore) {
		
			NSLog(@"Error adding persistent store: %@", persistentStoreAddingError);
				
			if ([[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
			
				[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
				continuesTrying = YES;
		
			} else {
			
				continuesTrying = NO;
			
			}
			
		} else {
		
			continuesTrying = NO;
		
		};
	
	}
	
	NSParameterAssert([persistentStoreCoordinator.persistentStores count]);
	return persistentStoreCoordinator;

}

- (void) setPersistentStoreName:(NSString *)newPersistentStoreName {

	if (persistentStoreName == newPersistentStoreName)
		return;
	
	NSLog(@"%s: %@ -> %@", __PRETTY_FUNCTION__, persistentStoreName, newPersistentStoreName);
	
	[persistentStoreName release];
	persistentStoreName = [newPersistentStoreName retain];

	self.persistentStoreCoordinator = nil;
	objc_setAssociatedObject(self, &kIRDataStore_DefaultAutoUpdatedMOC, nil, OBJC_ASSOCIATION_ASSIGN);
		
}

- (NSManagedObjectContext *) defaultAutoUpdatedMOC {

	__block NSManagedObjectContext *returnedContext = objc_getAssociatedObject(self, &kIRDataStore_DefaultAutoUpdatedMOC);
	
	if (!returnedContext) {
	
		returnedContext = [self disposableMOC];
		[returnedContext irBeginMergingFromSavesAutomatically];
		[returnedContext irPerformOnDeallocation: ^ {
			[returnedContext irStopMergingFromSavesAutomatically];
		}];
		
		objc_setAssociatedObject(self, &kIRDataStore_DefaultAutoUpdatedMOC, returnedContext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	}
	
	return returnedContext;

}

- (NSManagedObjectContext *) disposableMOC {

	NSLog(@"%s: Using %@", __PRETTY_FUNCTION__, self.persistentStoreCoordinator);

	NSManagedObjectContext *returnedContext = [[[NSManagedObjectContext alloc] init] autorelease];
	[returnedContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
	[returnedContext setUndoManager:nil];
	
	return returnedContext;

}

- (void) dealloc {

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

- (NSURL *) oneUsePersistentFileURL {

	NSString *documentDirectory = [(NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
	NSString *fileString = [documentDirectory stringByAppendingPathComponent:IRDataStoreNonce()];

	return [NSURL fileURLWithPath:fileString];

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

	NSURL *fileURL = [self oneUsePersistentFileURL];
	fileURL = [NSURL fileURLWithPath:[[fileURL path] stringByAppendingPathExtension:[[aURL path] pathExtension]]];
	

	NSError *copyError = nil;
	if (![[NSFileManager defaultManager] copyItemAtURL:aURL toURL:fileURL error:&copyError]) {
	
		NSLog(@"Error copying from %@ to %@: %@.  Creating intermediate directories.", aURL, fileURL, copyError);
		copyError = nil;
		
		NSError *directoryCreationError = nil;
		if (![[NSFileManager defaultManager] createDirectoryAtPath:[aURL path] withIntermediateDirectories:YES attributes:nil error:&directoryCreationError]) {
			NSLog(@"Error creating directory with intermediates: %@", directoryCreationError);
		}
		
		if (![[NSFileManager defaultManager] copyItemAtURL:aURL toURL:fileURL error:&copyError]) {
			NSLog(@"Error copying from %@ to %@: %@", aURL, fileURL, copyError);
		}
		
	}

	return fileURL;

}

- (NSURL *) persistentFileURLForFileAtPath:(NSString *)aPath {
	return [self persistentFileURLForFileAtURL:[NSURL fileURLWithPath:aPath]];
}

@end
