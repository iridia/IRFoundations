//
//  IRManagedObject+SimulatedOrderedRelationship.h
//  IRFoundations
//
//  Created by Evadne Wu on 12/8/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "IRManagedObject.h"

@interface IRManagedObject (SimulatedOrderedRelationship)

- (void) irReconcileObjectOrderWithKey:(NSString *)aKey usingArrayKeyed:(NSString *)arrayKey;

- (NSArray *) irBackingOrderArrayKeyed:(NSString *)aKey;

- (void) irUpdateObjects:(NSSet *)changedObjects withRelationshipKey:(NSString *)relationshipKey usingOrderArray:(NSString *)arrayKey withSetMutation:(NSKeyValueSetMutationKind)mutationKind;

@end
