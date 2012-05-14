//
//  IRManagedObjectContext.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/10/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "CoreData+IRAdditions.h"

#import "IRLifetimeHelper.h"
#import "IRManagedObjectContext.h"


@implementation NSManagedObjectContext (IRAdditions)

- (NSManagedObject *) irManagedObjectForURI:(NSURL *)anURI {

	NSManagedObject *returnedObject = nil;
	NSManagedObjectID *objectID = nil;

	@try {
	
		objectID = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:anURI];
		
		if (!objectID) {
		
			NSLog(@"%s: Object ID not recognized by persistent store coordinator.", __PRETTY_FUNCTION__);
			
			NSLog(@"%s: URI Representation: %@", __PRETTY_FUNCTION__, anURI);
			NSLog(@"%s: Object Store ID: %@", __PRETTY_FUNCTION__, [anURI host]);
			NSLog(@"%s: All Store IDs: %@", __PRETTY_FUNCTION__, [self.persistentStoreCoordinator.persistentStores irMap: ^ (NSPersistentStore *aStore, NSUInteger index, BOOL *stop) {
				return [aStore identifier];
			}]);
		
			return nil;
		
		}
		
		NSParameterAssert(![objectID isTemporaryID]);
		
		returnedObject = [self objectWithID:objectID];
	
	} @catch (NSException *exception) {
	
		NSLog(@"%s: Exception: %@", __PRETTY_FUNCTION__, exception);
		
	}
	
	return returnedObject;

}

@end


@interface IRManagedObjectContext ()

@property (nonatomic, readwrite, assign, setter=irSetAutoMergeStackCount:, getter=irAutoMergeStackCount) NSUInteger irAutoMergeStackCount;
@property (nonatomic, readwrite, retain) id irAutoMergeListener;

- (void) irAutoMergeSetUp;
- (void) irAutoMergeTearDown;

@end


@implementation IRManagedObjectContext
@synthesize irAutoMergeStackCount, irAutoMergeListener;

- (void) dealloc {

	if (irAutoMergeListener)
		[[NSNotificationCenter defaultCenter] removeObserver:irAutoMergeListener];

}

- (void) irBeginMergingFromSavesAutomatically {

	self.irAutoMergeStackCount = self.irAutoMergeStackCount + 1;
	
}

- (void) irStopMergingFromSavesAutomatically {

	self.irAutoMergeStackCount = self.irAutoMergeStackCount - 1;

}

- (BOOL) irIsMergingFromSavesAutomatically {

	return !!self.irAutoMergeStackCount;

}

- (void) irSetAutoMergeStackCount:(NSUInteger)newCount {

	NSUInteger oldCount = irAutoMergeStackCount;
	
	[self willChangeValueForKey:@"irAutoMergeStackCount"];
	
	irAutoMergeStackCount = newCount;
	
	if ((oldCount == 0) && (newCount == 1)) {
	
		[self irAutoMergeSetUp];
	
	} else if ((oldCount == 1) && (newCount == 0)) {
	
		[self irAutoMergeTearDown];
	
	}

	[self didChangeValueForKey:@"irAutoMergeStackCount"];
	
}

- (void) irAutoMergeSetUp {

	NSParameterAssert(!self.irAutoMergeListener);
	NSParameterAssert([NSThread isMainThread]);

	__weak IRManagedObjectContext *wSelf = self;
	
	self.irAutoMergeListener = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:nil usingBlock: ^ (NSNotification *note) {
	
		dispatch_async(dispatch_get_main_queue(), ^ {
		
			NSManagedObjectContext *savedContext = (NSManagedObjectContext *)note.object;
			if (!wSelf)
				return;
			
			if (savedContext == wSelf)
				return;
			
			if (savedContext.persistentStoreCoordinator != wSelf.persistentStoreCoordinator)
				return;
			
			//	Fire faults in wSelf for every single changed object.
			//	This works around an issue where if a NSFetchedResultsController has a predicate, it won’t watch objects changed to fit the predicate
			//	Also fixes production cases where Debug and Release behavior differs
			
			//	Hat tip: http://stackoverflow.com/questions/3923826/nsfetchedresultscontroller-with-predicate-ignores-changes-merged-from-different
			
			[wSelf mergeChangesFromContextDidSaveNotification:note];
			
			for (NSManagedObject *object in [[note userInfo] objectForKey:NSInsertedObjectsKey])
				[[wSelf objectWithID:[object objectID]] willAccessValueForKey:nil];

			for (NSManagedObject *object in [[note userInfo] objectForKey:NSUpdatedObjectsKey])
				[[wSelf objectWithID:[object objectID]] willAccessValueForKey:nil];

			for (NSManagedObject *object in [[note userInfo] objectForKey:NSDeletedObjectsKey])
				[[wSelf objectWithID:[object objectID]] willAccessValueForKey:nil];
			
			[wSelf processPendingChanges];
					
		});
		
	}];
	
}

- (void) irAutoMergeTearDown {
	
	NSParameterAssert(self.irAutoMergeListener);
	[[NSNotificationCenter defaultCenter] removeObserver:self.irAutoMergeListener];
	
	self.irAutoMergeListener = nil;

}

@end
