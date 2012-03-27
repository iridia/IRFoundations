//
//  UIView+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 8/3/11.
//  Copyright 2011 Waveface. All rights reserved.
//

#import "UIView+IRAdditions.h"

NSString * const kUIView_IRAdditions_onLayoutSubviews = @"UIView_IRAdditions_onLayoutSubviews";
NSString * const kUIView_IRAdditions_onDrawRect = @"UIView_IRAdditions_onDrawRect";
NSString * const kUIView_IRAdditions_onDrawLayerInContext = @"UIView_IRAdditions_onDrawLayerInContext";


void UIView_IRAdditions_layoutSubviews (UIView *self, SEL _cmd) {

	NSLog(@"%s overridden %@ %@", __PRETTY_FUNCTION__, self, NSStringFromSelector(_cmd));
	
	struct objc_super superInfo = (struct objc_super){
		self,
		class_getSuperclass(object_getClass(self))
	};
	objc_msgSendSuper(&superInfo, _cmd);
	
	if (self.onLayoutSubviews)
		self.onLayoutSubviews(self);

};


void UIView_IRAdditions_drawRect (UIView *self, SEL _cmd, CGRect aRect) {

	NSLog(@"%s overridden %@ %@ %@", __PRETTY_FUNCTION__, self, NSStringFromSelector(_cmd), NSStringFromCGRect(aRect));

	struct objc_super superInfo = (struct objc_super){ self, class_getSuperclass(object_getClass(self))	};
	objc_msgSendSuper(&superInfo, _cmd, aRect);
	
	if (self.onDrawRect)
		self.onDrawRect(self, aRect);

};


void UIView_IRAdditions_drawLayerInContext (UIView *self, SEL _cmd, CALayer *aLayer, CGContextRef aContext) {

	NSLog(@"%s overridden %@ %@ %@ %@", __PRETTY_FUNCTION__, self, NSStringFromSelector(_cmd), aLayer, aContext);
	
	struct objc_super superInfo = (struct objc_super){ self, class_getSuperclass(object_getClass(self))	};
	objc_msgSendSuper(&superInfo, _cmd, aLayer, aContext);	
	
	if (self.onDrawLayerInContext)
		self.onDrawLayerInContext(self, aLayer, aContext);

};


@implementation UIView (IRAdditions)

- (void) irCreateCustomSubclass {

	Class ownClass = self->isa;
	NSString *className = NSStringFromClass(ownClass);
	NSString *suffix = @"_$IRAdditions";
	
	if ([className hasSuffix:suffix])
		return;
	
	NSString *subclassName = [className stringByAppendingString:suffix];
	Class subclass = NSClassFromString(subclassName);

	if (subclass)
		return;
	
	subclass = objc_allocateClassPair(ownClass, [subclassName UTF8String], 0);
	if (!subclass)
		return;
		
	class_replaceMethod(subclass, @selector(layoutSubviews), (IMP)UIView_IRAdditions_layoutSubviews, method_getTypeEncoding(class_getInstanceMethod(subclass, @selector(layoutSubviews))));
	class_replaceMethod(subclass, @selector(drawRect:), (IMP)UIView_IRAdditions_drawRect, method_getTypeEncoding(class_getInstanceMethod(subclass, @selector(drawRect:))));
	class_replaceMethod(subclass, @selector(drawLayer:inContext:), (IMP)UIView_IRAdditions_drawLayerInContext, method_getTypeEncoding(class_getInstanceMethod(subclass, @selector(drawLayer:inContext:))));
	
	objc_registerClassPair(subclass);

	if (subclass)
		object_setClass(self, subclass);

}

- (void) setOnLayoutSubviews:(void (^)(UIView *))newOnLayoutSubviews {

	[self irCreateCustomSubclass];
	
	objc_setAssociatedObject(self, &kUIView_IRAdditions_onLayoutSubviews, newOnLayoutSubviews, OBJC_ASSOCIATION_COPY_NONATOMIC);

}

- (void) setOnDrawRect:(void (^)(UIView *, CGRect))newOnDrawRect {

	[self irCreateCustomSubclass];
	
	objc_setAssociatedObject(self, &kUIView_IRAdditions_onDrawRect, newOnDrawRect, OBJC_ASSOCIATION_COPY_NONATOMIC);

}

- (void) setOnDrawLayerInContext:(void (^)(UIView *, CALayer *, CGContextRef))newOnDrawLayerInContext {

	[self irCreateCustomSubclass];
	
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

- (UIView *) irFirstResponderInView {

	if (self.isFirstResponder)
		return self;
	
	for (UIView *aSubview in self.subviews) {
		UIView *foundFirstResponder = [aSubview performSelector:_cmd];
		if (foundFirstResponder)
			return foundFirstResponder;
	}
	
	return nil;

}

- (NSArray *) irSubviewsWithPredicate:(NSPredicate *)aPredicate {

	NSArray *returnedArray = [NSArray array];
	
	for (UIView *aSubview in self.subviews) {

		[returnedArray arrayByAddingObjectsFromArray:[aSubview irSubviewsWithPredicate:aPredicate]];

		if ([aPredicate evaluateWithObject:aSubview])
			returnedArray = [returnedArray arrayByAddingObject:aSubview];
			
	}
	
	return returnedArray;

}

- (UIView *) irAncestorInView:(UIView *)aView {

	if (![self isDescendantOfView:aView])
		return nil;
	
	if (self.superview == aView)
		return self;
	
	return [self.superview irAncestorInView:aView];

}

- (BOOL) irRemoveAnimationsRecusively:(BOOL)recursive {

	[self.layer removeAllAnimations];
	
	if (recursive)
	for (UIView *aSubview in self.subviews)
		[aSubview irRemoveAnimationsRecusively:YES];

}

@end


IRArrayMapCallback irMapFrameValuesFromViews () {

	return [[ ^ (UIView *aView, NSUInteger index, BOOL *stop) {

		return [NSValue valueWithCGRect:aView.frame];
	
	} copy] autorelease];

}

IRArrayMapCallback irMapBoundsValuesFromViews () {

	return [[ ^ (UIView *aView, NSUInteger index, BOOL *stop) {
	
		return [NSValue valueWithCGRect:aView.bounds];
	
	} copy] autorelease];

}

IRArrayMapCallback irMapOriginValuesFromRectValues () {

	return [[ ^ (NSValue *aRectValue, NSUInteger index, BOOL *stop) {

		return [NSValue valueWithCGPoint:[aRectValue CGRectValue].origin];	
	
	} copy] autorelease];

}

IRArrayMapCallback irMapCenterPointValuesFromRectValues () {

	return [[ ^ (NSValue *aRectValue, NSUInteger index, BOOL *stop) {

		return [NSValue valueWithCGPoint:irCGRectAnchor([aRectValue CGRectValue], irCenter, YES)];	
	
	} copy] autorelease];

}
