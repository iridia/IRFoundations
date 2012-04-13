//
//  UIApplication+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 11/18/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <objc/runtime.h>

#import "UIApplication+IRAdditions.h"

@implementation UIApplication (IRAdditions)

static void __attribute__((constructor)) initialize() {

	@autoreleasepool {
	
		Class class = [UIApplication class];

		method_exchangeImplementations(
			class_getInstanceMethod(class, @selector(_ir_overridden_setStatusBarHidden:withAnimation:)),
			class_getInstanceMethod(class, @selector(setStatusBarHidden:withAnimation:))
		);
			
	}
	
}

static int ignoringCount = 0;

- (void) irBeginIgnoringStatusBarAppearanceRequests {

	ignoringCount ++;

}

- (void) irEndIgnoringStatusBarAppearanceRequests {

	ignoringCount --;	

}

- (void) _ir_overridden_setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation {

	if (ignoringCount)
		return;
	
	[self _ir_overridden_setStatusBarHidden:hidden withAnimation:animation];

}

@end
