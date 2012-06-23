//
//  NSObject+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSObject+IRAdditions.h"

@implementation NSObject (IRAdditions)

- (void) irExecute {

	((void(^)(void))self)();

}

- (BOOL) irIsBlock {

	static NSSet *potentialClassNames = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		potentialClassNames = [NSSet setWithObjects:
			@"_NSConcreteStackBlock", 
			@"_NSConcreteGlobalBlock",
			@"NSStackBlock",
			@"NSGlobalBlock",
			@"NSMallocBlock",
			@"NSBlock",
		nil];
	});

	NSString *ownClass = NSStringFromClass([self class]);
	for (NSString *aClassName in potentialClassNames)
		if ([ownClass isEqualToString:aClassName])
			return YES;

	return NO;

}

+ (BOOL) irHasDifferentSuperClassMethodForSelector:(SEL)aSelector {

	Method ownMethod = class_getClassMethod([self class], aSelector);
	Method superMethod = class_getClassMethod([self superclass], aSelector);
	
	return (superMethod && (superMethod != ownMethod));

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

- (void) irAssociateObject:(id)anObject usingKey:(const void *)aKey policy:(objc_AssociationPolicy)policy changingObservedKey:(NSString *)propertyKeyOrNil {

	if ([self irAssociatedObjectWithKey:aKey] == anObject)
		return;

	if (propertyKeyOrNil)
		[self willChangeValueForKey:propertyKeyOrNil];
	
	objc_setAssociatedObject(self, aKey, anObject, policy);
	
	if (propertyKeyOrNil)
		[self didChangeValueForKey:propertyKeyOrNil];

}

- (id) irAssociatedObjectWithKey:(const void *)aKey {

	return objc_getAssociatedObject(self, aKey);

}

@end


NSComparator irComparatorMakeWithNodeKeyPath (NSString *aKeyPath) {

	return (NSComparator)[ ^ (id lhs, id rhs) {
	
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

	} copy];

}


NSUInteger irCount (id anObject, NSUInteger placeholderValue) {

	if ([anObject isKindOfClass:[NSDictionary class]])
	return 1;
	
	if ([anObject respondsToSelector:@selector(count)])
	return (NSUInteger)[(NSObject *)anObject performSelector:@selector(count)];
	
	return NSNotFound;

}
