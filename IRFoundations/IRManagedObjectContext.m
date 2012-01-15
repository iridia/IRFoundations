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
#import "NSFetchRequest+IRAdditions.h"


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

- (NSArray *) executeFetchRequest:(NSFetchRequest *)request error:(NSError **)error {

	for (NSString *aPrefetchedRelationshipKeyPath in [[request.irRelationshipKeyPathsForObjectsPrefetching copy] autorelease]) {
	
		NSLog(@"Prefetch %@", aPrefetchedRelationshipKeyPath);
	
	}

	return [super executeFetchRequest:request error:error];

}

- (void) dealloc {

	if (irAutoMergeListener) {
		[[NSNotificationCenter defaultCenter] removeObserver:irAutoMergeListener];
		[irAutoMergeListener release];
	}
	
	[super dealloc];

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

	dispatch_queue_t (^currentQueue)() = ^ {
		return [NSThread isMainThread] ? dispatch_get_main_queue() : dispatch_get_current_queue();
	};

	__block __typeof__(self) nrSelf = self;
	__block dispatch_queue_t ownQueue = currentQueue();
	dispatch_retain(ownQueue);
	
	__block id listenerObject = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:nil usingBlock: ^ (NSNotification *note) {
		
		NSManagedObjectContext *savedContext = (NSManagedObjectContext *)note.object;
		
		if (savedContext == nrSelf)
			return;
		
		if (savedContext.persistentStoreCoordinator != nrSelf.persistentStoreCoordinator)
			return;
			
		void (^merge)(void) = ^ {
			
			@try {
				[nrSelf mergeChangesFromContextDidSaveNotification:note];
			} @catch (NSException *e) {
				NSLog(@"%@", e);
			}
		
		};
			
		if (ownQueue == currentQueue())
			merge();
		else 
			dispatch_async(ownQueue, merge);
		
	}];
	
	[listenerObject irPerformOnDeallocation:^{
	
		dispatch_release(ownQueue);
		
	}];

	self.irAutoMergeListener = listenerObject;

}

- (void) irAutoMergeTearDown {
	
	NSParameterAssert(self.irAutoMergeListener);
	[[NSNotificationCenter defaultCenter] removeObserver:self.irAutoMergeListener];

}

- (void) irHandleManagedObjectContextDidSaveNotification:(NSNotification *)note {
	
	NSParameterAssert([self irIsMergingFromSavesAutomatically]);
	
	__block __typeof__(self) nrSelf = self;
	
	
}

@end
