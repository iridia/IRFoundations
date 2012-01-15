//
//  IRCoreDataTest.m
//  IRFoundations
//
//  Created by Evadne Wu on 1/15/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRCoreDataTest.h"
#import "CoreData+IRAdditions.h"
#import "IRCoreDataTestObject.h"


@interface IRCoreDataTest ()

@property (nonatomic, readwrite, retain) IRDataStore *dataStore;
@property (nonatomic, readwrite, retain) NSManagedObjectModel *managedObjectModel;

- (BOOL) hasPersistentStoreBackingFile;

@end


@implementation IRCoreDataTest
@synthesize dataStore, managedObjectModel;

- (void) setUp {

	[super setUp];
	
	self.managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"IRCoreDataTestModel" withExtension:@"momd"]] autorelease];

	self.dataStore = [[[IRDataStore alloc] initWithManagedObjectModel:self.managedObjectModel] autorelease];
	
	NSURL *storeURL = [self.dataStore defaultPersistentStoreURL];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:[storeURL path]])
		[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

}

- (void) tearDown {

	self.managedObjectModel = nil;
	self.dataStore = nil;

	[super tearDown];

}

- (void) testStackCompletion {

	STAssertNotNil(self.dataStore.persistentStoreCoordinator, @"The Data Store should already have a persistent store coordinator");

}

- (void) testNoInitialFile {

	STAssertFalse(
		[self hasPersistentStoreBackingFile],
		@"Data Store should not have an initial file after -setUp"
	);

}

- (void) testBackingFileExistsWithPersistentStoreCoordinator {

	[self testNoInitialFile];
	
	NSPersistentStoreCoordinator *coordinator = self.dataStore.persistentStoreCoordinator;
	STAssertNotNil(coordinator, @"Data Store should return a coordinator");
	STAssertTrue([self hasPersistentStoreBackingFile], @"Data Store should now have a persistent store backing file");

}

- (void) testAutoMerging {

	__block IRDataStore *nrDataStore = self.dataStore;	
	STAssertFalse([self hasPersistentStoreBackingFile], @"Backing file should NOT exist at this time");
	
	__block NSManagedObjectContext *nrAutoUpdatedMOC = [nrDataStore defaultAutoUpdatedMOC];
	STAssertNotNil(nrAutoUpdatedMOC, @"Auto-updated MOC should exist");
	STAssertTrue([self hasPersistentStoreBackingFile], @"Backing file should exist as long as something started using the MOC");
	
	__block NSURL *savedObjectURL = nil;
	
	dispatch_sync(dispatch_get_global_queue(0, 0), ^{
	
		NSManagedObjectContext *context = [nrDataStore disposableMOC];
		IRCoreDataTestObject *savedObject = [IRCoreDataTestObject objectInsertingIntoContext:context withRemoteDictionary:[NSDictionary dictionary]];
		
		NSError *error = nil;
		BOOL didSave = [context save:&error];
		
		savedObjectURL = [[[savedObject objectID] URIRepresentation] retain];
		
		STAssertTrue(didSave, @"Just save it");
		STAssertNil(error, @"Saving error: %@", error);
		
	});
	
	STAssertNotNil(savedObjectURL, @"Saved object should exist");
	IRCoreDataTestObject *savedObject = (IRCoreDataTestObject *)[nrAutoUpdatedMOC irManagedObjectForURI:savedObjectURL];
	
	STAssertNotNil(savedObject, @"Saved object should be merged into the auto-updated MOC");
	
	[savedObjectURL autorelease];

}

- (void) testPersistentStoreNameChange {

	NSPersistentStoreCoordinator *oldCoordinator = [[dataStore.persistentStoreCoordinator retain] autorelease];
	NSURL *oldBackingFile = [[dataStore.defaultPersistentStoreURL retain] autorelease];
	NSManagedObjectContext *oldAutoUpdatedMOC = [[[dataStore defaultAutoUpdatedMOC] retain] autorelease];
	
	dataStore.persistentStoreName = [dataStore.persistentStoreName stringByAppendingString:IRDataStoreNonce()];
	
	STAssertFalse([oldCoordinator isEqual:dataStore.persistentStoreCoordinator], @"Store should be using a new coordinator");
	STAssertFalse([oldBackingFile isEqual:dataStore.defaultPersistentStoreURL], @"Store should be using a new backing file");
	STAssertFalse([oldAutoUpdatedMOC isEqual:[dataStore defaultAutoUpdatedMOC]], @"Store should be using a new auto-updated MOC");
	
	void (^saveBlock)(void) = ^ {
	
		NSManagedObjectContext *disposableContext = [dataStore disposableMOC];
		[IRCoreDataTestObject objectInsertingIntoContext:disposableContext withRemoteDictionary:[NSDictionary dictionary]];
		NSError *savingError = nil;
		
		STAssertTrue([disposableContext save:&savingError], @"Context should have saved: %@", savingError);
	
	};
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_group_t group = dispatch_group_create();
	 
	dispatch_group_async(group, queue, saveBlock);

	dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
	dispatch_release(group);

}

#if IRCoreDataTest_HardAssMode

- (void) testPersistentStoreNameChange_100x {

	[self tearDown];
	
	for (int i = 0; i < 100; i++) {
		[self setUp];
		[self testPersistentStoreNameChange];
		[self tearDown];
	}

	[self setUp];

}

#endif

- (BOOL) hasPersistentStoreBackingFile {

	return [[NSFileManager defaultManager] fileExistsAtPath:[[self.dataStore defaultPersistentStoreURL] path]];

}

@end
