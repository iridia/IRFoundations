//
//  IRManagedObject+SimulatedOrderedRelationship.m
//  IRFoundations
//
//  Created by Evadne Wu on 12/8/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <objc/runtime.h>
#import "IRManagedObject+SimulatedOrderedRelationship.h"


NSString * const kObservingSetUp = @"IRManagedObject_SimulatedOrderedRelationship_ObservingSetUp";


@interface NSManagedObject (SimulatedOrderedRelationshipRouting)

- (NSMutableArray *) baseMutableArrayValueForKey:(NSString *)key;
- (void) baseSetValue:(id)value forKey:(NSString *)key;
- (id) baseValueForKey:(NSString *)key;

@end

@implementation NSManagedObject (SimulatedOrderedRelationshipRouting)

- (NSMutableArray *) baseMutableArrayValueForKey:(NSString *)key {

	return [super mutableArrayValueForKey:key];

}

- (void) baseSetValue:(id)value forKey:(NSString *)key {

	[super setValue:value forKey:key];

}

- (id) baseValueForKey:(NSString *)key {
	
	return [super valueForKey:key];

}

@end


@interface IRManagedObject (SimulatedOrderedRelationship_Private)

@property (nonatomic, readwrite, assign) BOOL hasConfiguredObserving;

@end

@implementation IRManagedObject (SimulatedOrderedRelationship_Private)

- (void) setHasConfiguredObserving:(BOOL)flag {

	objc_setAssociatedObject(self, &kObservingSetUp, (id)(flag ? kCFBooleanTrue : kCFBooleanFalse), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (BOOL) hasConfiguredObserving {

	return [objc_getAssociatedObject(self, &kObservingSetUp) isEqual:(id)kCFBooleanTrue];

}

@end


@implementation IRManagedObject (SimulatedOrderedRelationship)

+ (void) configureSimulatedOrderedRelationship {

	Class class = [self class];
	
	SEL protoInsertSel = @selector(insertObject:inInferredBackingArrayAtIndex:);
	Method protoInsertMethod = class_getInstanceMethod(class, protoInsertSel);
	IMP protoInsertImpl = method_getImplementation(protoInsertMethod);
	const char * protoInsertMethodTypeEncoding = method_getTypeEncoding(protoInsertMethod);
	
	SEL protoRemoveSel = @selector(removeObjectfromInferredBackingArrayAtIndex:);
	Method protoRemoveMethod = class_getInstanceMethod(class, protoRemoveSel);
	IMP protoRemoveImpl = method_getImplementation(protoRemoveMethod);
	const char * protoRemoveMethodTypeEncoding = method_getTypeEncoding(protoRemoveMethod);
	
	[[self orderedRelationships] enumerateKeysAndObjectsUsingBlock: ^ (NSString *setKey, NSString *arrayKey, BOOL *stop) {
	
		NSAssert1([setKey length], @"Set key name %@ must have at least one character.", setKey);
		NSAssert1([arrayKey length], @"Backing array key name %@ must have at least one character.", arrayKey);
		
		NSRange headRange = (NSRange){ 0, 1 };
		NSString *arrayKeyFragment =  [arrayKey stringByReplacingCharactersInRange:headRange withString:[[arrayKey substringWithRange:headRange] uppercaseString]];
	
		SEL insertSel = NSSelectorFromString([NSString stringWithFormat:@"insertObject:in%@AtIndex:", arrayKeyFragment]);
		SEL removeSel = NSSelectorFromString([NSString stringWithFormat:@"removeObjectFrom%@AtIndex:", arrayKeyFragment]);
		
		class_addMethod(class, insertSel, protoInsertImpl, protoInsertMethodTypeEncoding);
		class_addMethod(class, removeSel, protoRemoveImpl, protoRemoveMethodTypeEncoding);
		
		[self setArrayKey:arrayKey forAccessorSelector:insertSel];
		[self setArrayKey:arrayKey forAccessorSelector:removeSel];
		
	}];

}

+ (NSMutableDictionary *) accessorSelectorsToArrayKeys {

	static NSString *key = @"IRManagedObject_SimulatedOrderedRelationship_accessorSelectorsToArrayKeys";
	
	NSMutableDictionary *dictionary = objc_getAssociatedObject(self, &key);
	if (!dictionary) {
		dictionary = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &key, dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return dictionary;
	
}

+ (NSString *) arrayKeyForAccessorSelector:(SEL)selector {

	return [[self accessorSelectorsToArrayKeys] objectForKey:NSStringFromSelector(selector)];

}

+ (void) setArrayKey:(NSString *)arrayKey forAccessorSelector:(SEL)selector {

	NSParameterAssert(arrayKey);
	NSParameterAssert(selector);

	[[self accessorSelectorsToArrayKeys] setObject:arrayKey forKey:NSStringFromSelector(selector)];

}

+ (NSDictionary *) orderedRelationships {

	return nil;

}

+ (BOOL) automaticallyNotifiesObserversForKey:(NSString *)key {

	if ([super automaticallyNotifiesObserversForKey:key])
		return YES;
	
	if ([[[self accessorSelectorsToArrayKeys] allKeys] containsObject:key])
		return YES;
	
	if ([[[self accessorSelectorsToArrayKeys] allValues] containsObject:key])
		return YES;
	
	return NO;

}

- (void) simulatedOrderedRelationshipInit {

	//	No op for now

}

- (void) simulatedOrderedRelationshipAwake {

	[[[self class] orderedRelationships] enumerateKeysAndObjectsUsingBlock: ^ (NSString *setKey, NSString *arrayKey, BOOL *stop) {
		
		[self irReconcileObjectOrderWithKey:setKey usingArrayKeyed:arrayKey];
		
		if (!self.hasConfiguredObserving) {
		
			[self.managedObjectContext lock];
		
			[self addObserver:self forKeyPath:setKey options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:self];
			[self addObserver:self forKeyPath:arrayKey options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:self];
			
			self.hasConfiguredObserving = YES;
		
			[self.managedObjectContext unlock];
			
		}

	}];

}

- (void) simulatedOrderedRelationshipWillTurnIntoFault {

	[[[self class] orderedRelationships] enumerateKeysAndObjectsUsingBlock: ^ (NSString *setKey, NSString *arrayKey, BOOL *stop) {
	
		if (self.hasConfiguredObserving) {
		
			[self removeObserver:self forKeyPath:setKey context:self];
			[self removeObserver:self forKeyPath:arrayKey context:self];
			
			self.hasConfiguredObserving = NO;
		
		}
		
	}];

}

- (void) simulatedOrderedRelationshipDealloc {

	[[[self class] orderedRelationships] enumerateKeysAndObjectsUsingBlock: ^ (NSString *setKey, NSString *arrayKey, BOOL *stop) {
	
		if (self.hasConfiguredObserving) {
		
			[self removeObserver:self forKeyPath:setKey context:self];
			[self removeObserver:self forKeyPath:arrayKey context:self];
			
			self.hasConfiguredObserving = NO;
		
		}
		
	}];

}

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

	NSArray *returnedOrder = [self primitiveValueForKey:aKey];
	if (!returnedOrder) {
		returnedOrder = [NSArray array];
		[self setPrimitiveValue:returnedOrder forKey:aKey];
	}
		
	return returnedOrder;

}

- (id) irObjectAtIndex:(NSUInteger)anIndex inArrayKeyed:(NSString *)arrayKey {

	NSArray *backingArray = [self irBackingOrderArrayKeyed:arrayKey];
	NSURL *anURL = [backingArray objectAtIndex:anIndex];
	
	return [self.managedObjectContext irManagedObjectForURI:anURL];

}

- (id) valueForKey:(NSString *)key {

//	NSLog(@"%s %@ %x", __PRETTY_FUNCTION__, key, (unsigned int)[NSThread currentThread]);

	NSParameterAssert(key);

	if ([[[[self class] orderedRelationships] allValues] containsObject:key])
		return [self irBackingOrderArrayKeyed:key];

	return [super valueForKey:key];

}

- (void) insertObject:(id)object inInferredBackingArrayAtIndex:(NSUInteger)index {

	NSParameterAssert([object isKindOfClass:[NSURL class]]);

	NSString *arrayKey = [[self class] arrayKeyForAccessorSelector:_cmd];
	NSParameterAssert(arrayKey);
	
	NSArray *backingArray = [self valueForKey:arrayKey];
	NSMutableArray *mutatedArray = [[backingArray mutableCopy] autorelease];
	[mutatedArray insertObject:object atIndex:index];
	[self baseSetValue:mutatedArray forKey:arrayKey];

}

- (void) removeObjectfromInferredBackingArrayAtIndex:(NSUInteger)index {

	NSString *arrayKey = [[self class] arrayKeyForAccessorSelector:_cmd];
	NSParameterAssert(arrayKey);
	
	NSArray *backingArray = [self valueForKey:arrayKey];
	NSMutableArray *mutatedArray = [[backingArray mutableCopy] autorelease];
	[mutatedArray removeObjectAtIndex:index];
	[self baseSetValue:mutatedArray forKey:arrayKey];

}

- (NSMutableArray *) mutableArrayValueForKey:(NSString *)key {

	if ([[[[self class] orderedRelationships] allValues] containsObject:key])
		return [self baseMutableArrayValueForKey:key];
	
	return [super mutableArrayValueForKey:key];

}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

	if ([super irHasDifferentSuperInstanceMethodForSelector:_cmd])
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	
	if (object == self) {
	
		NSDictionary *relationships = [[self class] orderedRelationships];
		NSKeyValueChange changeType = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
		
		if ([[relationships allKeys] containsObject:keyPath]) {
		
			NSSet *oldSet = [change objectForKey:NSKeyValueChangeOldKey];
			NSSet *newSet = [change objectForKey:NSKeyValueChangeNewKey];
			
			if ([oldSet isEqual:[NSNull null]])
				oldSet = nil;
			
			if ([newSet isEqual:[NSNull null]])
				newSet = nil;
			
			if (![oldSet isEqualToSet:newSet]) {
			
				NSString *setKey = keyPath;
				NSString *arrayKey = [relationships objectForKey:setKey];
				NSMutableArray *mutableArray = [self mutableArrayValueForKey:arrayKey];
				NSParameterAssert(mutableArray);
				
				[self.managedObjectContext obtainPermanentIDsForObjects:[newSet allObjects] error:nil];

				NSArray *newObjectURIs = [[newSet allObjects] irMap: ^ (NSManagedObject *anObject, NSUInteger index, BOOL *stop) {
					return [[anObject objectID] URIRepresentation];
				}];
				
				//	Update the order array to reflect the change
				
				NSArray *removedURIs = [mutableArray irMap: ^ (NSURL *objectURI, NSUInteger index, BOOL *stop) {
				
					if ([newObjectURIs containsObject:objectURI])
						return (NSURL *)nil;
					
					return objectURI;
					
				}];
				
				if ([removedURIs count])
					[mutableArray removeObjectsInArray:removedURIs];
				
				NSArray *insertedURIs = [newObjectURIs irMap: ^ (NSURL *objectURI, NSUInteger index, BOOL *stop) {
				
					if ([mutableArray containsObject:objectURI])
						return (NSURL *)nil;
					
					return objectURI;
					
				}];
				
				if ([insertedURIs count])
					[mutableArray addObjectsFromArray:insertedURIs];
				
				NSLog(@"mutableArray -> %@", mutableArray);
			
			}
						
		} else if ([[relationships allValues] containsObject:keyPath]) {
		
			NSArray *oldArray = [change objectForKey:NSKeyValueChangeOldKey];
			NSArray *newArray = [change objectForKey:NSKeyValueChangeNewKey];
			
			if ([oldArray isEqual:[NSNull null]])
				oldArray = nil;
			
			if ([newArray isEqual:[NSNull null]])
				newArray = nil;
			
			if (![oldArray isEqualToArray:newArray]) {
			
				NSString *setKey = [[relationships allKeysForObject:keyPath] lastObject];
				NSString *arrayKey = keyPath;
				NSMutableSet *mutableSet = [[[self valueForKey:setKey] mutableCopy] autorelease];
				if (!mutableSet)
					mutableSet = [NSMutableSet set];
				
				NSSet *newObjects = [(NSSet *)[NSSet setWithArray:newArray] irMap: ^ (NSURL *anObjectURI, BOOL *stop) {
				
					return [self.managedObjectContext irManagedObjectForURI:anObjectURI];
					
				}];
				
				[mutableSet minusSet:[mutableSet irMap: ^ (NSManagedObject *object, BOOL *stop) {
				
					if ([newArray containsObject:[[object objectID] URIRepresentation]])
						return (NSManagedObject *)nil;
				
					return object;
					
				}]];
				
				[mutableSet unionSet:newObjects];
				
				[self setValue:mutableSet forKey:setKey];
				
				NSLog(@"%@: -> %@", setKey, mutableSet);
			
			}
		
		}
	
	}

}

@end
