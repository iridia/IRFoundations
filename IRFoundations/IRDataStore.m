//
//  IRDataStore.m
//  IRFoundations
//
//  Created by Evadne Wu on 7/21/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDataStore.h"

@interface IRDataStore ()

@property (nonatomic, readwrite, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readwrite, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readwrite, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation IRDataStore

@synthesize managedObjectContext, managedObjectModel, persistentStoreCoordinator;

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
	if (!self) return nil;
	
	return self;

}

- (NSManagedObjectModel *) defaultManagedObjectModel {

	[NSException raise:NSInternalInconsistencyException format:@"Subclasses shall provide a custom managed object model."];
	return nil;

}

- (NSURL *) defaultPersistentStoreURL {

	NSString *defaultFilename = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingPathExtension:@"sqlite"];
	
	return [(NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:defaultFilename];

}

- (IRDataStore *) initWithManagedObjectModel:(NSManagedObjectModel *)model {

	self = [super init];
	if (!self) return nil;
	
	if (!model) {
		model = [self defaultManagedObjectModel];
        NSParameterAssert(model);
	}
	
	self.managedObjectModel = model;
	self.persistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel] autorelease];
	self.managedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
	[self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];	
	
	NSURL *storeURL = [self defaultPersistentStoreURL];
	
	BOOL continuesTrying = YES;
	
	while (continuesTrying) {
	
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
	
	NSParameterAssert([self.persistentStoreCoordinator.persistentStores count]);

	return self;

}

- (NSManagedObjectContext *) disposableMOC {

	NSManagedObjectContext *returnedContext = [[[NSManagedObjectContext alloc] init] autorelease];
	[returnedContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
	[returnedContext setUndoManager:nil];
	
	return returnedContext;

}

- (void) dealloc {

	[managedObjectModel release];
	[managedObjectContext release];
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

	NSURL *fileURL = [self oneUsePersistentFileURL];
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
