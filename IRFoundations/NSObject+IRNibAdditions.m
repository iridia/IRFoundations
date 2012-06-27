//
//  NSObject+IRNibAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 4/4/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSObject+IRNibAdditions.h"
#import "Foundation+IRAdditions.h"

#import <objc/runtime.h>
#import <objc/message.h>


@implementation NSObject (IRNibAdditions)

+ (id) instanceFromNib {

	__block id (^objectForClass)(Class) = ^ (Class aClass) {
	
		@try {
		
			NSNib *ownNib = [[NSNib alloc] initWithNibNamed:NSStringFromClass(aClass) bundle:[NSBundle bundleForClass:aClass]];
			NSArray *nibObjects = nil;
			
			if ([ownNib instantiateNibWithOwner:nil topLevelObjects:&nibObjects]) {
				
				NSArray *siblingObjects = [nibObjects irMap: ^ (id inObject, NSUInteger index, BOOL *stop) {
					return [inObject isKindOfClass:aClass] ? inObject : nil;
				}];
				
				return [siblingObjects lastObject];
			
			}
		
		} @catch (NSException *exception) {

			if (aClass == [NSResponder class])
				return (id)nil;

			return objectForClass([aClass superclass]);
		
		}

		if (aClass == [NSResponder class])
			return (id)nil;

		return objectForClass([aClass superclass]);

	};
		
	return objectForClass([self class]);
	
}

@end
