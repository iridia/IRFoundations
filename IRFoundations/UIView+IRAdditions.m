//
//  UIView+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 8/3/11.
//  Copyright 2011 Waveface. All rights reserved.
//

#import "UIView+IRAdditions.h"


@implementation UIView (IRAdditions)

- (UIView *) irFirstResponderInView {

	if (self.isFirstResponder)
		return self;
	
	for (UIView *aSubview in self.subviews) {
		UIView *foundFirstResponder = [aSubview irFirstResponderInView];
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

	return [ ^ (UIView *aView, NSUInteger index, BOOL *stop) {

		return [NSValue valueWithCGRect:aView.frame];
	
	} copy];
	
}

IRArrayMapCallback irMapBoundsValuesFromViews () {

	return [ ^ (UIView *aView, NSUInteger index, BOOL *stop) {
	
		return [NSValue valueWithCGRect:aView.bounds];
	
	} copy];

}

IRArrayMapCallback irMapOriginValuesFromRectValues () {

	return [ ^ (NSValue *aRectValue, NSUInteger index, BOOL *stop) {

		return [NSValue valueWithCGPoint:[aRectValue CGRectValue].origin];	
	
	} copy];

}

IRArrayMapCallback irMapCenterPointValuesFromRectValues () {

	return [ ^ (NSValue *aRectValue, NSUInteger index, BOOL *stop) {

		return [NSValue valueWithCGPoint:irCGRectAnchor([aRectValue CGRectValue], irCenter, YES)];	
	
	} copy];

}
