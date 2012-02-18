//
//  NSArray+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSArray+IRAdditions.h"


@implementation NSArray (IRAdditions)

- (NSArray *) irMap:(id(^)(id inObject, NSUInteger index, BOOL *stop))mapBlock {

	NSMutableArray *returnedArray = [NSMutableArray arrayWithCapacity:[self count]];

	NSUInteger index = 0;
	BOOL stop = NO;

	for (id object in self) {
	
		id returnedObject = mapBlock(object, index, &stop);
		
		if (returnedObject)
		[returnedArray addObject:returnedObject];
		
		index++;
		
		if (stop)
		break;
			
	}
	
	return returnedArray;

}

- (NSArray *) irUnique {

	return [[NSSet setWithArray:self] allObjects];

}

- (NSArray *) irFlatten {

	NSMutableArray *returnedArray = [NSMutableArray array];
	
	[self enumerateObjectsUsingBlock: ^ (id obj, NSUInteger idx, BOOL *stop) {
		
		if ([obj isEqual:[NSNull null]])
		return;
		
		if ([obj isKindOfClass:[NSArray class]]) {
		
			[returnedArray addObjectsFromArray:obj];
			
		} else {
		
			[returnedArray addObject:obj];
			
		}

	}];
	
	return returnedArray;

}

+ (NSArray *) irArrayByRepeatingObject:(id)anObject count:(NSUInteger)count {

	NSMutableArray *returnedArray = [NSMutableArray arrayWithCapacity:count];
	
	for (int i = 0; i < count; i ++)
	[returnedArray addObject:anObject];

	return returnedArray;

}

- (void) irExecuteAllObjectsAsBlocks {

//	This method can explode if there are things that are not blocks!

	for (void(^aBlock)(void) in self)
	aBlock();

}

- (NSArray *) irSubarraysByBreakingArrayIntoBatchesOf:(NSInteger)maxCountPerSubarray {

	NSMutableArray *returnedArray = [NSMutableArray array];
	
	NSUInteger exhausted = 0;
	
	while (exhausted < [self count]) {
	
		NSUInteger elementsAdded = MIN([self count] - exhausted, maxCountPerSubarray);
	
		[returnedArray addObject:[self subarrayWithRange:(NSRange){ exhausted, elementsAdded }]];
		
		exhausted += elementsAdded;
	
	}
	
	return returnedArray;

}

- (NSArray *) irShuffle {
	NSMutableArray *returnedArray = [[self mutableCopy] autorelease];
	[returnedArray irShuffle];
	return returnedArray;
}

@end





@implementation NSMutableArray (IRAdditions)

- (void) irEnqueueBlock:(void(^)(void))aBlock {

	[self addObject:[[aBlock copy] autorelease]];

}

- (void) irShuffle {

	NSUInteger count = [self count];
	
	for (unsigned int i = 0; i < count; ++i)
	[self exchangeObjectAtIndex:i withObjectAtIndex:((arc4random() % (count - i)) + i)];

}

+ (NSMutableArray *) irArrayByRepeatingObject:(id)anObject count:(NSUInteger)count {

	return (NSMutableArray *)[super irArrayByRepeatingObject:anObject count:count];

}

@end


IRMapCallback irMapMakeWithKeyPath (NSString * inKeyPath) {
	
	return (IRMapCallback)[[ ^ (id object, NSUInteger index, BOOL *stop) {
	
		id returnedObject = [object valueForKeyPath:inKeyPath];
		return returnedObject ? returnedObject : [NSNull null];
	
	} copy] autorelease];
 
};

IRMapCallback irMapNullFilterMake () {

	return (IRMapCallback)[[ ^ (id object, NSUInteger index, BOOL *stop) {

		return (!object || [object isEqual:[NSNull null]]) ? nil : object;
	
	} copy] autorelease];

}
