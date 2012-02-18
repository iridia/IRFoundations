//
//  UIScrollView+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/10/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "objc/runtime.h"

#import "UIScrollView+IRAdditions.h"


static void __attribute__((constructor)) initialize() {

	@autoreleasepool {
			
		Class class = [UIScrollView class];
		
		Method panGestureRecognizerMethod = class_getInstanceMethod(class, @selector(panGestureRecognizer));
		if (!panGestureRecognizerMethod) {
			
			Method method = class_getInstanceMethod(class, @selector(irPanGestureRecognizer));
			if (method) {
			
				const char *typeEncoding = method_getTypeEncoding(panGestureRecognizerMethod);
				IMP implementation = method_getImplementation(panGestureRecognizerMethod);
				if (!class_addMethod(class, @selector(panGestureRecognizer), implementation, typeEncoding))
					NSLog(@"Error adding -[UIScrollView panGestureRecognizer]");
				
			}
			
		}
		
		
		Method pinchGestureRecognizerMethod = class_getInstanceMethod(class, @selector(pinchGestureRecognizer));
		if (!pinchGestureRecognizerMethod) {
			
			Method method = class_getInstanceMethod(class, @selector(irPinchGestureRecognizer));
			if (method) {
			
				const char *typeEncoding = method_getTypeEncoding(method);
				IMP implementation = method_getImplementation(pinchGestureRecognizerMethod);
				
				if (!class_addMethod(class, @selector(pinchGestureRecognizer), implementation, typeEncoding))
					NSLog(@"Error adding -[UIScrollView pinchGestureRecognizer]");
				
			}
			
		}
		
	}
	
}

@implementation UIScrollView (IRAdditions)

@dynamic panGestureRecognizer, pinchGestureRecognizer;

- (UIPanGestureRecognizer *) irPanGestureRecognizer {

	for (UIGestureRecognizer *aGR in self.gestureRecognizers)
		if ([aGR isKindOfClass:[UIPanGestureRecognizer class]])
			return (UIPanGestureRecognizer *)aGR;
		
	return nil;

}

- (UIPinchGestureRecognizer *) irPinchGestureRecognizer {

	for (UIGestureRecognizer *aGR in self.gestureRecognizers)
		if ([aGR isKindOfClass:[UIPinchGestureRecognizer class]])
			if (self.maximumZoomScale > self.minimumZoomScale)
				return (UIPinchGestureRecognizer *)aGR;
	
	return nil;

}

@end
