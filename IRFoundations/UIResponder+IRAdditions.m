//
//  UIResponder+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 3/2/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "UIResponder+IRAdditions.h"
#import "Foundation+IRAdditions.h"

#import <objc/runtime.h>
#import <objc/message.h>


@implementation UIResponder (IRAdditions)

+ (id) instanceFromNib {

	__block id (^objectForClass)(Class) = ^ (Class aClass) {
	
		@try {
		
			UINib *ownNib = [UINib nibWithNibName:NSStringFromClass(aClass) bundle:[NSBundle bundleForClass:aClass]];
			NSArray *nibObjects = [ownNib instantiateWithOwner:nil options:nil];
			NSArray *siblingObjects = [nibObjects irMap: ^ (id inObject, NSUInteger index, BOOL *stop) {
				return [inObject isKindOfClass:aClass] ? inObject : nil;
			}];
			
			return [siblingObjects lastObject];
		
		} @catch (NSException *exception) { 

			if (aClass == [UIResponder class])
				return nil;

			return objectForClass([aClass superclass]);
		
		}

	};
		
	return objectForClass([self class]);
	
}

@end
