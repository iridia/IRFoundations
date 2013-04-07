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
	
	id (^objectForClass)(Class, void *) = ^ (Class aClass, void *continuation) {
	
		NSBundle * const bundle = [NSBundle bundleForClass:aClass];
		NSString * const nibName = NSStringFromClass(aClass);
		
		id (^uproot)(void) = ^ {
			return (aClass == [UIResponder class]) ?
				nil :
				((__bridge id(^)(Class, void*))continuation)([aClass superclass], continuation);
		};
		
		if (![bundle pathForResource:nibName ofType:@"nib"])
		if (![bundle pathForResource:nibName ofType:@"xib"])
			return uproot();
		
		@try {
			for (id nibObject in [[UINib nibWithNibName:nibName bundle:bundle] instantiateWithOwner:nil options:nil]) {
				if ([nibObject isKindOfClass:aClass]) {
					return nibObject;
				}
			}
		} @catch (NSException *exception) {
			return uproot();
		}
		
		return uproot();

	};
	
	return objectForClass([self class], (__bridge void *)objectForClass);
	
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
