//
//  IRManagedObject+SimulatedOrderedRelationship.h
//  IRFoundations
//
//  Created by Evadne Wu on 12/8/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "IRManagedObject.h"

@interface IRManagedObject (SimulatedOrderedRelationship)

//	Call in -awakeFromFetch
- (void) irReconcileObjectOrderWithKey:(NSString *)aKey usingArrayKeyed:(NSString *)arrayKey;

//	Call in array getter
- (NSArray *) irBackingOrderArrayKeyed:(NSString *)aKey;

//	Convenience
- (id) irObjectAtIndex:(NSUInteger)anIndex inArrayKeyed:(NSString *)arrayKey;

//	Call in -didChangeValueForKey:withSetMutation:usingObjects:
- (void) irUpdateObjects:(NSSet *)changedObjects withRelationshipKey:(NSString *)relationshipKey usingOrderArray:(NSString *)arrayKey withSetMutation:(NSKeyValueSetMutationKind)mutationKind;

@end
