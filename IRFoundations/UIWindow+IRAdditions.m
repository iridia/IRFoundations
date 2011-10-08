//
//  UIWindow+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 9/7/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <objc/runtime.h>
#import "UIWindow+IRAdditions.h"

NSString * const kIRWindowInterfaceBounds = @"kIRWindowInterfaceBounds";

@interface UIWindow (IRAdditionsPrivate)

@property (nonatomic, readwrite, assign) CGRect irInterfaceBounds;

- (void) irAdjustInterfaceBoundsWithKeyboardRect:(CGRect)aRect;

@end

@implementation UIWindow (IRAdditionsPrivate)

- (CGRect) irInterfaceBounds {

	return [objc_getAssociatedObject(self, &kIRWindowInterfaceBounds) CGRectValue];

}

- (void) setIrInterfaceBounds:(CGRect)newBounds {

	CGRect oldBounds = [self irInterfaceBounds];
	if (CGRectEqualToRect(oldBounds, newBounds))
		return;
	
	[self willChangeValueForKey:@"irInterfaceBounds"];
	objc_setAssociatedObject(self, &kIRWindowInterfaceBounds, [NSValue valueWithCGRect:newBounds], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey:@"irInterfaceBounds"];
	
}

- (void) irAdjustInterfaceBoundsWithKeyboardRect:(CGRect)aRect {

	//	Pretty sure this method is 10x as bloated as it needs to be

	CGRect convertedRect = [self convertRect:[self convertRect:aRect fromWindow:nil] fromView:nil];
	CGRect tempRect = CGRectNull;
	CGRect avoidedMinX, avoidedMaxX, avoidedMinY, avoidedMaxY; 
	
	__block CGRect bestRect = CGRectZero;
	__block CGFloat bestRectSize = 0.0f;
	
	void (^buff)(CGRect) = ^ (CGRect candidate) {
		CGFloat size = CGRectGetWidth(candidate) * CGRectGetHeight(candidate);
		if (size > bestRectSize) {
			if (!CGRectEqualToRect(candidate, self.frame)) {
				bestRectSize = size;
				bestRect = candidate;
			}
		}
	};
	
	CGRectDivide(self.bounds, &tempRect, &avoidedMinX, CGRectGetMaxX(convertedRect), CGRectMinXEdge);
	buff(avoidedMinX);

	CGRectDivide(self.bounds, &tempRect, &avoidedMinY, CGRectGetMaxY(convertedRect), CGRectMinYEdge);
	buff(avoidedMinY);

	CGRectDivide(self.bounds, &avoidedMaxX, &tempRect, CGRectGetMinX(convertedRect), CGRectMinXEdge);
	buff(avoidedMaxX);
	
	CGRectDivide(self.bounds, &avoidedMaxY, &tempRect, CGRectGetMinY(convertedRect), CGRectMinYEdge);
	buff(avoidedMaxY);
	
	if (!bestRectSize)
		bestRect = self.bounds;
	
	self.irInterfaceBounds = bestRect;

}

@end


@implementation UIWindow (IRAdditions)
@dynamic irInterfaceBounds;

+ (void) initialize {

	static dispatch_once_t onceToken = 0;
	dispatch_once(&onceToken, ^ {
	
		method_exchangeImplementations(
			class_getInstanceMethod(self, @selector(becomeKeyWindow)),
			class_getInstanceMethod(self, @selector(ir_becomeKeyWindow))
		);

		//	method_exchangeImplementations(
		//		class_getInstanceMethod(self, @selector(resignKeyWindow)),
		//		class_getInstanceMethod(self, @selector(ir_resignKeyWindow))
		//	);
		
	});
	
}

- (void) ir_becomeKeyWindow {

	[self ir_becomeKeyWindow];
	[self irAdjustInterfaceBoundsWithKeyboardRect:CGRectZero];
		
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		void (^handleNotification)(NSNotification *) = ^ (NSNotification *aNotification) {
		
			CGRect keyboardEndFrame = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
			
			for (UIWindow *aWindow in [UIApplication sharedApplication].windows)
				if ([aWindow isMemberOfClass:[UIWindow class]])
					[aWindow irAdjustInterfaceBoundsWithKeyboardRect:keyboardEndFrame];

		};
	
		[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:handleNotification];
		//	[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:handleNotification];
		[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:handleNotification];
		//	[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidHideNotification object:nil queue:nil usingBlock:handleNotification];
			
	});

}

//	- (void) ir_resignKeyWindow {
//
//		NSLog(@"%s; %@", __PRETTY_FUNCTION__, NSStringFromSelector(_cmd));
//
//		[self ir_resignKeyWindow];
//		
//	}

@end
