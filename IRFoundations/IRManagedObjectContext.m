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


static NSString * const kIRManagedObjectContextDidSaveNotificationObservingCount = @"IRManagedObjectContextDidSaveNotificationObservingCount";
static NSString * const kIRManagedObjectContextDidSaveNotificationListener = @"IRManagedObjectContextDidSaveNotificationListener";


@interface NSManagedObjectContext (IRAdditions_Private)

@property (nonatomic, readwrite, assign, setter=irSetMOCSaveAutomergeCount:, getter=irMOCSaveAutomergeCount) int irMOCSaveAutomergeCount;

@end


@implementation NSManagedObjectContext (IRAdditions_Private)

- (void) irSetMOCSaveAutomergeCount:(int)newCount {

	objc_setAssociatedObject(self, &kIRManagedObjectContextDidSaveNotificationObservingCount, [NSNumber numberWithInt:newCount], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (int) irMOCSaveAutomergeCount {

	NSNumber *currentNumber = objc_getAssociatedObject(self, &kIRManagedObjectContextDidSaveNotificationObservingCount);
	
	return currentNumber ? [currentNumber intValue] : 0;

}

@end


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

- (void) irBeginMergingFromSavesAutomatically {

	if (self.irMOCSaveAutomergeCount == 0) {
	
		__block __typeof__(self) nrSelf = self;
		__block dispatch_queue_t ownQueue = [NSThread isMainThread] ? dispatch_get_main_queue() : dispatch_get_current_queue();
		dispatch_retain(ownQueue);
		
		__block id listenerObject = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:nil usingBlock: ^ (NSNotification *note) {
		
			dispatch_async(ownQueue, ^ {
		
				[nrSelf mergeChangesFromContextDidSaveNotification:note];
			
			});
			
			dispatch_release(ownQueue);
			
		}];
		
		[listenerObject irPerformOnDeallocation: ^ {
		
			[[NSNotificationCenter defaultCenter] removeObserver:listenerObject];
			
		}];
		
		objc_setAssociatedObject(self, &kIRManagedObjectContextDidSaveNotificationListener, listenerObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	}

	self.irMOCSaveAutomergeCount = self.irMOCSaveAutomergeCount + 1;

}

- (void) irStopMergingFromSavesAutomatically {

	self.irMOCSaveAutomergeCount = self.irMOCSaveAutomergeCount - 1;
	
	if (!self.irMOCSaveAutomergeCount) {

		objc_setAssociatedObject(self, &kIRManagedObjectContextDidSaveNotificationListener, nil, OBJC_ASSOCIATION_ASSIGN);
	
		NSLog(@"%@ should stop observing and merging", self);
	
	}

}

- (BOOL) irIsMergingFromSavesAutomatically {

	NSParameterAssert(!!self.irMOCSaveAutomergeCount == !!objc_getAssociatedObject(self, &kIRManagedObjectContextDidSaveNotificationListener));
	
	return (self.irMOCSaveAutomergeCount > 0);

}

@end





@implementation IRManagedObjectContext

- (NSArray *) executeFetchRequest:(NSFetchRequest *)request error:(NSError **)error {

	for (NSString *aPrefetchedRelationshipKeyPath in [[request.irRelationshipKeyPathsForObjectsPrefetching copy] autorelease]) {
	
		NSLog(@"Prefetch %@", aPrefetchedRelationshipKeyPath);
	
	}

	return [super executeFetchRequest:request error:error];

}

@end
