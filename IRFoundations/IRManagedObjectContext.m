//
//  IRManagedObjectContext.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/10/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "CoreData+IRAdditions.h"

#import "IRManagedObjectContext.h"
#import "NSFetchRequest+IRAdditions.h"


@implementation NSManagedObjectContext (IRAdditions)

- (NSManagedObject *) irManagedObjectForURI:(NSURL *)anURI {

	NSManagedObject *returnedObject = nil;
	NSManagedObjectID *objectID = nil;

	@try {
	
		objectID = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:anURI];
		
		if (!objectID) {
		
		//	Object ID not recognized by persistent store coordinator.
		//	Diagnostics here
		
			NSLog(@"Managed Object ID’s URI Representation: %@, represented identifier %@, registered persistent store identifiers: %@", 
			
				anURI, 
				
				[anURI host],
				
				[[[self persistentStoreCoordinator] persistentStores] irMap: ^ (NSPersistentStore *aStore, int index, BOOL *stop) {
				
					return [aStore identifier];
				
				}]
				
			);
		
			return nil;
		
		}
		returnedObject = [self objectWithID:objectID];
	
	} @catch (NSException *exception) {
	
		NSLog(@"Exception: %@", exception);
		
	}
	
	return returnedObject;

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
