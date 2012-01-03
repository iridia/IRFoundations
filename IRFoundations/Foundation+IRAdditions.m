//
//  Foundation+IRAdditions.m
//  Milk
//
//  Created by Evadne Wu on 1/14/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "Foundation+IRAdditions.h"


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

IRMapCallback irMapFrameValuesFromViews () {

	return (IRMapCallback)[[ ^ (UIView *aView, NSUInteger index, BOOL *stop) {

		return [NSValue valueWithCGRect:aView.frame];
	
	} copy] autorelease];

}

IRMapCallback irMapBoundsValuesFromViews () {

	return (IRMapCallback)[[ ^ (UIView *aView, NSUInteger index, BOOL *stop) {

		return [NSValue valueWithCGRect:aView.bounds];
	
	} copy] autorelease];

}

IRMapCallback irMapOriginValuesFromRectValues () {

	return (IRMapCallback)[[ ^ (NSValue *aRectValue, NSUInteger index, BOOL *stop) {

		return [NSValue valueWithCGPoint:[aRectValue CGRectValue].origin];	
	
	} copy] autorelease];

}

IRMapCallback irMapCenterPointValuesFromRectValues () {

	return (IRMapCallback)[[ ^ (NSValue *aRectValue, NSUInteger index, BOOL *stop) {

		return [NSValue valueWithCGPoint:irCGRectAnchor([aRectValue CGRectValue], irCenter, YES)];	
	
	} copy] autorelease];

}






NSComparator irComparatorMakeWithNodeKeyPath (NSString *aKeyPath) {

	return (NSComparator)[[ ^ (id lhs, id rhs) {
	
		BOOL (^empty)() = ^ (id aValue) {
		
			return (BOOL)(!aValue || [aValue isEqual:[NSNull null]]);
			
		};

		BOOL lhsNull = empty(lhs), rhsNull = empty(rhs);
		
		NSComparisonResult (^resultsFromBooleans)(BOOL lBool, BOOL rBool) = ^ (BOOL lBool, BOOL rBool) {
		
			if (lBool && rBool) return (NSComparisonResult)NSOrderedSame;
			if (lBool) return (NSComparisonResult)NSOrderedAscending;
			if (rBool) return (NSComparisonResult)NSOrderedDescending;
			
			return (NSComparisonResult)NSOrderedSame;
		
		};
		
		if (lhsNull || rhsNull)
		return resultsFromBooleans(!lhsNull, !rhsNull);
		
		
		id	lhsValue = [lhs valueForKeyPath:aKeyPath],
			rhsValue = [rhs valueForKeyPath:aKeyPath];
		
		BOOL	lhsComparable = [lhsValue respondsToSelector:@selector(compare:)],
			rhsComparable = [rhsValue respondsToSelector:@selector(compare:)];
			
		if (!lhsComparable || !rhsComparable)
		return resultsFromBooleans(!lhsComparable, !rhsComparable);
		
		return [lhsValue compare:rhsValue];

	} copy] autorelease];

}





NSUInteger irCount (id anObject, NSUInteger placeholderValue) {

	if ([anObject isKindOfClass:[NSDictionary class]])
	return 1;
	
	if ([anObject respondsToSelector:@selector(count)])
	return (NSUInteger)[(NSObject *)anObject performSelector:@selector(count)];
	
	return NSNotFound;

}






void IRLogExceptionAndContinue (void(^operation)(void)) {

	@try {
	
		operation();
	
	} @catch (NSException *exception) {
	
		NSLog(@"Exception: %@", exception);
		@throw exception;
	
	}

}










@implementation NSObject (IRAdditions)

- (void) irExecute {

	((void(^)(void))self)();

}

- (BOOL) irIsBlock {

	static NSSet *potentialClassNames = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		potentialClassNames = [[NSSet setWithObjects:
			@"_NSConcreteStackBlock", 
			@"_NSConcreteGlobalBlock",
			@"NSStackBlock",
			@"NSGlobalBlock",
			@"NSMallocBlock",
			@"NSBlock",
		nil] retain];
	});

	NSString *ownClass = NSStringFromClass([self class]);
	for (NSString *aClassName in potentialClassNames)
		if ([ownClass isEqualToString:aClassName])
			return YES;

	return NO;

}

- (BOOL) irHasDifferentSuperClassMethodForSelector:(SEL)aSelector {

	Method ownMethod = class_getClassMethod([self class], aSelector);
	Method superMethod = class_getClassMethod([self superclass], aSelector);
	
	return (superMethod && (superMethod != ownMethod));

}

- (BOOL) irHasDifferentSuperInstanceMethodForSelector:(SEL)aSelector {

	Method ownMethod = class_getInstanceMethod([self class], aSelector);
	Method superMethod = class_getInstanceMethod([self superclass], aSelector);
	
	return (superMethod && (superMethod != ownMethod));

}

@end





@implementation NSString (IRAdditions)

- (NSString *) irTailTruncatedStringWithMaxLength:(NSUInteger)maxCharacters {

	return [[self substringToIndex:MIN([self length], maxCharacters)] stringByAppendingString:([self length] > maxCharacters) ? @"…" : @""];

}

@end





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





@implementation NSDictionary (IRAdditions)

- (BOOL) irPassesTestSuite:(NSDictionary *)aSuite {

	__block BOOL passes = YES;
	
	[aSuite enumerateKeysAndObjectsUsingBlock: ^ (id key, id obj, BOOL *stop) {
	
		IRDictionaryPairTest aTest = [aSuite objectForKey:key];
		
		if (!aTest || aTest(key, [self objectForKey:key]))
			return;
		
		passes = NO;
		*stop = YES;
		
	}];
	
	return passes;

}

- (NSDictionary *) irDictionaryBySettingObject:(id)anObject forKey:(NSString *)aKey {

	return [self irDictionaryByMergingWithDictionary:[NSDictionary dictionaryWithObject:anObject forKey:aKey]];

}

- (NSDictionary *) irDictionaryByMergingWithDictionary:(NSDictionary *)aDictionary {

	NSMutableDictionary *copy = [[self mutableCopy] autorelease];
	[aDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		[copy setObject:obj forKey:key];
	}];
	return copy;

}

@end

@implementation NSSet (IRAdditions)

- (NSSet *) irSetByRemovingObjectsInSet:(NSSet *)subtractedSet {

	NSMutableSet *returnedSet = [[self mutableCopy] autorelease];
	[returnedSet minusSet:subtractedSet];
	
	return [[returnedSet copy] autorelease];

}

@end





@implementation NSThread (IRAdditions)

+ (void) irLogCallStackSymbols {

	NSLog(@"%@", [self callStackSymbols]);

}

@end



