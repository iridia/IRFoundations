//
//  IRView.m
//  IRFoundations
//
//  Created by Evadne Wu on 1/6/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRView.h"


@implementation IRView
@synthesize onHitTestWithEvent, onPointInsideWithEvent, onLayoutSubviews, onSizeThatFits, onDrawRect;

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {

	UIView *superAnswer = [super hitTest:point withEvent:event];

	if (self.onHitTestWithEvent) {
		UIView *ownAnswer = self.onHitTestWithEvent(point, event, superAnswer);
		if (ownAnswer)
			return ownAnswer;
	}
	
	return superAnswer;

}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {

	BOOL superAnswer = [super pointInside:point withEvent:event];

	if (self.onPointInsideWithEvent)
		return onPointInsideWithEvent(point, event, superAnswer);
	
	return superAnswer;
	
}

- (void) layoutSubviews {

	[super layoutSubviews];

	if (self.onLayoutSubviews)
		self.onLayoutSubviews();

}

- (CGSize) sizeThatFits:(CGSize)size {

	CGSize superSize = [super sizeThatFits:size];
	if (self.onSizeThatFits)
		return self.onSizeThatFits(size, superSize);
	
	return superSize;

}

- (void) drawRect:(CGRect)rect {

	if (self.onDrawRect)
		self.onDrawRect(rect, UIGraphicsGetCurrentContext());

}

@end
