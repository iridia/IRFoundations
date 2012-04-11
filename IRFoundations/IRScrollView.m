//
//  WAScrollView.m
//  wammer
//
//  Created by Evadne Wu on 1/30/12.
//  Copyright (c) 2012 Waveface. All rights reserved.
//

#import "IRScrollView.h"
#import "Foundation+IRAdditions.h"


@interface UIScrollView (WAScrollView_Private) <UIGestureRecognizerDelegate>
@end


@interface IRScrollView () <UIGestureRecognizerDelegate>
@end

@implementation IRScrollView
@synthesize onTouchesShouldBeginWithEventInContentView;
@synthesize onTouchesShouldCancelInContentView;
@synthesize onGestureRecognizerShouldBegin;
@synthesize onGestureRecognizerShouldReceiveTouch;
@synthesize onGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer;

- (BOOL) touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {

	BOOL superAnswer = [super touchesShouldBegin:touches withEvent:event inContentView:view];
	
	if (self.onTouchesShouldBeginWithEventInContentView)
		return self.onTouchesShouldBeginWithEventInContentView(touches, event, view);
	
	return superAnswer;

}

- (BOOL) touchesShouldCancelInContentView:(UIView *)view {

	BOOL superAnswer = [super touchesShouldCancelInContentView:view];
	
	if (self.onTouchesShouldCancelInContentView)
		return self.onTouchesShouldCancelInContentView(view);
	
	return superAnswer;

}

- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

	BOOL superAnswer = YES;
	if ([self irHasDifferentSuperInstanceMethodForSelector:_cmd])
		superAnswer = [super gestureRecognizerShouldBegin:gestureRecognizer];

	if (self.onGestureRecognizerShouldBegin)
		return self.onGestureRecognizerShouldBegin(gestureRecognizer, superAnswer);

	return superAnswer;

}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

	BOOL superAnswer = YES;

	if ([self irHasDifferentSuperInstanceMethodForSelector:_cmd])
		superAnswer = [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
	
	if (self.onGestureRecognizerShouldReceiveTouch)
		return self.onGestureRecognizerShouldReceiveTouch(gestureRecognizer, touch, superAnswer);
	
	return superAnswer;

}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

	BOOL superAnswer = YES;
	
	if ([self irHasDifferentSuperInstanceMethodForSelector:_cmd])
		superAnswer = [super gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
	
	if (self.onGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer)
		return self.onGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer(gestureRecognizer, otherGestureRecognizer, superAnswer);

	return superAnswer;

}

@end
