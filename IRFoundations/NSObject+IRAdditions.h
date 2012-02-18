//
//  NSObject+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@interface NSObject (IRAdditions)

- (void) irExecute; // typecasts object to (void)(^)(void)
- (BOOL) irIsBlock;

- (BOOL) irHasDifferentSuperClassMethodForSelector:(SEL)aSelector;
- (BOOL) irHasDifferentSuperInstanceMethodForSelector:(SEL)aSelector;

- (void) irAssociateObject:(id)anObject usingKey:(const void *)aKey policy:(objc_AssociationPolicy)policy changingObservedKey:(NSString *)propertyKeyOrNil;	//	if propertyKeyOrNil is nil, no KVO notification sent

- (id) irAssociatedObjectWithKey:(const void *)aKey;

@end

extern NSComparator irComparatorMakeWithNodeKeyPath (NSString *aKeyPath);
extern NSUInteger irCount (id anObject, NSUInteger placeholderValue);
