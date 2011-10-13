//
//  IRView.m
//  Milk
//
//  Created by Evadne Wu on 1/6/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRView.h"


NSString * const kUIView_IRAdditions_onLayoutSubviews = @"UIView_IRAdditions_onLayoutSubviews";
NSString * const kUIView_IRAdditions_onDrawRect = @"UIView_IRAdditions_onDrawRect";
NSString * const kUIView_IRAdditions_onDrawLayerInContext = @"UIView_IRAdditions_onDrawLayerInContext";


@implementation UIView (IRAdditions)

- (void) setOnLayoutSubviews:(void (^)(UIView *))newOnLayoutSubviews {

	objc_setAssociatedObject(self, &kUIView_IRAdditions_onLayoutSubviews, newOnLayoutSubviews, OBJC_ASSOCIATION_COPY_NONATOMIC);

}

- (void) setOnDrawRect:(void (^)(UIView *, CGRect))newOnDrawRect {

	objc_setAssociatedObject(self, &kUIView_IRAdditions_onDrawRect, newOnDrawRect, OBJC_ASSOCIATION_COPY_NONATOMIC);

}

- (void) setOnDrawLayerInContext:(void (^)(UIView *, CALayer *, CGContextRef))newOnDrawLayerInContext {

	objc_setAssociatedObject(self, &kUIView_IRAdditions_onDrawLayerInContext, newOnDrawLayerInContext, OBJC_ASSOCIATION_COPY_NONATOMIC);

}

- (void(^)(UIView *)) onLayoutSubviews {

	return objc_getAssociatedObject(self, &kUIView_IRAdditions_onLayoutSubviews);

}

- (void(^)(UIView *, CGRect)) onDrawRect {

	return objc_getAssociatedObject(self, &kUIView_IRAdditions_onDrawRect);

}

- (void(^)(UIView *, CALayer *, CGContextRef)) onDrawLayerInContext {

	return objc_getAssociatedObject(self, &kUIView_IRAdditions_onDrawLayerInContext);

}

@end


@implementation IRView

@synthesize onDrawRect;

- (void) drawRect:(CGRect)rect {

	if (self.onDrawRect)
	self.onDrawRect(rect, UIGraphicsGetCurrentContext());

}

- (void) dealloc {

	self.onDrawRect = nil;

	[super dealloc];

}


@end
