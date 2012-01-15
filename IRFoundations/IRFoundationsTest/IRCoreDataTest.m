//
//  IRCoreDataTest.m
//  IRFoundations
//
//  Created by Evadne Wu on 1/15/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRCoreDataTest.h"
#import "CoreData+IRAdditions.h"


@interface IRCoreDataTest ()

@property (nonatomic, readwrite, retain) IRDataStore *dataStore;
@property (nonatomic, readwrite, retain) NSManagedObjectModel *managedObjectModel;

@end


@implementation IRCoreDataTest
@synthesize dataStore, managedObjectModel;

- (void) setUp {

	[super setUp];
	
	self.managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"IRCoreDataTestModel" withExtension:@"momd"]] autorelease];

	self.dataStore = [[[IRDataStore alloc] initWithManagedObjectModel:self.managedObjectModel] autorelease];

}

- (void) tearDown {

	self.managedObjectModel = nil;
	self.dataStore = nil;

	[super tearDown];

}

- (void) testStackCompletion {

	STAssertNotNil(self.dataStore.persistentStoreCoordinator, @"The Data Store should already have a persistent store coordinator");

}

- (void) testInitialFile {
    STAssertTrue((1 + 1) == 2, @"Compiler isn't feeling well today :-(");
}

@end
