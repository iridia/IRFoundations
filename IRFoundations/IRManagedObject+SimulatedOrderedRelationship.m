//
//  IRManagedObject+SimulatedOrderedRelationship.m
//  IRFoundations
//
//  Created by Evadne Wu on 12/8/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "IRManagedObject+SimulatedOrderedRelationship.h"

@implementation IRManagedObject (SimulatedOrderedRelationship)

- (void) irReconcileObjectOrderWithKey:(NSString *)aKey usingArrayKeyed:(NSString *)arrayKey {

	NSArray *primitiveOrder = [self primitiveValueForKey:arrayKey];
	if (!primitiveOrder)
		primitiveOrder = [NSArray array];
    
  NSSet *currentObjectsSet = [self valueForKey:aKey];
  NSArray *currentObjectsArray = [currentObjectsSet allObjects];
	[self.managedObjectContext obtainPermanentIDsForObjects:currentObjectsArray error:nil];
	
	NSArray *currentObjectIDs = [currentObjectsArray irMap: ^ (NSManagedObject *anObject, NSUInteger index, BOOL *stop) {
		return [anObject objectID];
	}];
	
  NSArray *currentObjectURIs = [currentObjectIDs irMap: ^ (NSManagedObjectID *anObjectID, NSUInteger index, BOOL *stop) {
    return [anObjectID URIRepresentation];
  }];
  
	if ([primitiveOrder count] != [currentObjectURIs count]) {
	
		NSMutableArray *reconciledOrder = [NSMutableArray array];
		for (NSURL *anObjectURI in primitiveOrder)
			if (![reconciledOrder containsObject:anObjectURI])
				if ([currentObjectURIs containsObject:anObjectURI])
					[reconciledOrder addObject:anObjectURI];
		
		primitiveOrder = reconciledOrder;
		
	}
	
	NSSet *orderedObjectURIs = [NSSet setWithArray:primitiveOrder];
	NSSet *existingObjectURIs = [NSSet setWithArray:currentObjectURIs];
		
	if (![orderedObjectURIs isEqual:existingObjectURIs]) {
	
		NSMutableArray *newPrimitiveOrder = [[primitiveOrder mutableCopy] autorelease];
		
		[newPrimitiveOrder removeObjectsAtIndexes:[newPrimitiveOrder indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
			return (BOOL)(![existingObjectURIs containsObject:obj]);
		}]];
		
		[newPrimitiveOrder addObjectsFromArray:[[existingObjectURIs objectsPassingTest:^BOOL(id obj, BOOL *stop) {
			return (BOOL)(![orderedObjectURIs containsObject:obj]);
		}] allObjects]];
	
	}
		
	[self setPrimitiveValue:primitiveOrder forKey:arrayKey];

}

- (NSArray *) irBackingOrderArrayKeyed:(NSString *)aKey {

	NSArray *returnedOrder = nil;

	@try {

		returnedOrder = [self primitiveValueForKey:aKey];

	} @catch (NSException *exception) {
	
		NSLog(@"%s: %@", __PRETTY_FUNCTION__, exception);
		returnedOrder = [NSArray array];
	
	}
		
	if (!returnedOrder) {
		returnedOrder = [NSArray array];
		[self setPrimitiveValue:returnedOrder forKey:aKey];
	}
		
	return returnedOrder;

}

- (void) irUpdateObjects:(NSSet *)changedObjects withRelationshipKey:(NSString *)relationshipKey usingOrderArray:(NSString *)arrayKey withSetMutation:(NSKeyValueSetMutationKind)mutationKind {

  //  Call super, then this method in:
  //  - (void) didChangeValueForKey:(NSString *)inKey withSetMutation:(NSKeyValueSetMutationKind)inMutationKind usingObjects:(NSSet *)inObjects

	[self.managedObjectContext obtainPermanentIDsForObjects:[changedObjects allObjects] error:nil];
  
  NSArray *existingOrder = [self valueForKey:arrayKey];
	
  NSArray *changedObjectURIs = [[changedObjects allObjects] irMap: ^ (NSManagedObject *anObject, NSUInteger index, BOOL *stop) {
		return [[anObject objectID] URIRepresentation];
	}];
	
	switch (mutationKind) {
	
		case NSKeyValueUnionSetMutation: {
		
			NSMutableArray *newOrder = [[existingOrder mutableCopy] autorelease];
			
			[newOrder addObjectsFromArray:[changedObjectURIs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock: ^ (id evaluatedObject, NSDictionary *bindings) {
		
				return (BOOL)![existingOrder containsObject:evaluatedObject];
				
			}]]];
		
      [self setValue:newOrder forKey:arrayKey];
			
			break;
			
		}
		
		case NSKeyValueMinusSetMutation: {
			
      NSMutableArray *newOrder = [[existingOrder mutableCopy] autorelease];
			
			[newOrder removeObjectsInArray:changedObjectURIs];
			
      [self setValue:newOrder forKey:arrayKey];
      
			break;
			
		}
		
		case NSKeyValueIntersectSetMutation: {
		
			NSMutableArray *newOrder = [[existingOrder mutableCopy] autorelease];
			
			[newOrder removeObjectsInArray:changedObjectURIs];
			
			[newOrder addObjectsFromArray:[changedObjectURIs filteredArrayUsingPredicate:[NSPredicate predicateWithBlock: ^ (id evaluatedObject, NSDictionary *bindings) {
		
				return (BOOL)![existingOrder containsObject:evaluatedObject];
				
			}]]];
			
      [self setValue:newOrder forKey:arrayKey];
			
			break;
			
		}
		
		case NSKeyValueSetSetMutation: {
		
      [self setValue:changedObjectURIs forKey:arrayKey];
			
			break;
			
		}
	
	}

}

@end
