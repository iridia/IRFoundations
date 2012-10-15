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

static NSString * const kPreviousResponder = @"-[UIResponder ir_previousResponder]";
static NSString * const kNextResponder = @"-[UIResponder ir_nextResponder]";

@implementation UIResponder (IRAdditions)

+ (id) instanceFromNib {

	__block id (^objectForClass)(Class) = ^ (Class aClass) {
	
		NSBundle *bundle = [NSBundle bundleForClass:aClass];
		NSString *nibName = NSStringFromClass(aClass);
		
		id (^bail)(void) = ^ {
		
			if (aClass == [UIResponder class])
				return (id)nil;

			return objectForClass([aClass superclass]);

		};
		
		if (![bundle pathForResource:nibName ofType:@"nib"] && ![bundle pathForResource:nibName ofType:@"xib"])
			return bail();

		@try {
		
			UINib *ownNib = [UINib nibWithNibName:nibName bundle:bundle];
			NSArray *nibObjects = [ownNib instantiateWithOwner:nil options:nil];
			NSArray *siblingObjects = [nibObjects irMap: ^ (id inObject, NSUInteger index, BOOL *stop) {
				return [inObject isKindOfClass:aClass] ? inObject : nil;
			}];
			
			return [siblingObjects lastObject];
		
		} @catch (NSException *exception) { 

			return bail();
		
		}

	};
		
	return objectForClass([self class]);
	
}

- (void) setIr_previousResponder:(UIResponder *)ir_previousResponder {

	objc_setAssociatedObject(self, &kPreviousResponder, ir_previousResponder, OBJC_ASSOCIATION_ASSIGN);

}

- (UIResponder *) ir_previousResponder {

	return objc_getAssociatedObject(self, &kPreviousResponder);

}

- (void) setIr_nextResponder:(UIResponder *)ir_nextResponder {

	objc_setAssociatedObject(self, &kNextResponder, ir_nextResponder, OBJC_ASSOCIATION_ASSIGN);

}

- (UIResponder *) ir_nextResponder {

	return objc_getAssociatedObject(self, &kNextResponder);

}

@end
