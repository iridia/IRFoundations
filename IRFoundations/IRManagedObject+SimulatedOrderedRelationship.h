//
//  IRManagedObject+SimulatedOrderedRelationship.h
//  IRFoundations
//
//  Created by Evadne Wu on 12/8/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "IRManagedObject.h"

@interface IRManagedObject (SimulatedOrderedRelationship)

+ (void) configureSimulatedOrderedRelationship;	//	Call in your subclass’s +load to support array mutation methods

- (void) simulatedOrderedRelationshipInit;	//	Called by base class
- (void) simulatedOrderedRelationshipAwake;	//	Called by base class
- (void) simulatedOrderedRelationshipWillTurnIntoFault;	//	Called by base class
- (void) simulatedOrderedRelationshipDealloc;	//	Called by base class

+ (NSDictionary *) orderedRelationships;
- (id) irObjectAtIndex:(NSUInteger)anIndex inArrayKeyed:(NSString *)arrayKey;

@end
