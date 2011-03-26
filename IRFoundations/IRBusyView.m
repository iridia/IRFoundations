//
//  IRBusyView.m
//  IRFoundations
//
//  Created by Evadne Wu on 3/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRBusyView.h"
#import "IRActivityIndicatorView.h"

@implementation IRBusyView

@synthesize contentView, busyOverlayView, style;

+ (IRBusyView *) wrappedBusyViewForView:(UIView *)wrappedView withStyle:(IRBusyViewStyle)aStyle {

	IRBusyView *returnedView = [[[self alloc] initWithFrame:CGRectZero] autorelease];
	if (!returnedView) return nil;
	
	returnedView.contentView = wrappedView;
	returnedView.style = aStyle;
	
	[returnedView configureForPresetStyle:aStyle];
	[returnedView setNeedsLayout];
	
	return returnedView;

}

- (void) configureForPresetStyle:(IRBusyViewStyle)aStyle {

	switch (self.style) {
	
		case IRBusyViewStyleDefaultSpinner: {
		
			IRActivityIndicatorView *activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
			activityIndicator.hidesWhenStopped = YES;	
			activityIndicator.animating = NO;
			activityIndicator.userInteractionEnabled = NO;
			
			self.busyOverlayView = activityIndicator;
			
			break;
		
		}
		
		default: {
			
			NSParameterAssert(NO);
			break;
			
		}
	
	}

}

- (void) dealloc {

	[contentView release];
	[busyOverlayView release];
	
	[super dealloc];

}

- (void) setContentView:(UIView *)aView {

	if (contentView == aView)
	return;

	[contentView removeFromSuperview];
	[contentView release];
	contentView = [aView retain];
	[self addSubview:contentView];
	
	[self setNeedsLayout];

}

- (void) setBusyOverlayView:(UIView *)aView {

	if (busyOverlayView == aView)
	return;

	[busyOverlayView removeFromSuperview];
	[busyOverlayView release];
	busyOverlayView = [aView retain];
	[self addSubview:busyOverlayView];
	[self bringSubviewToFront:busyOverlayView];
	
	[self setNeedsLayout];

}

- (void) layoutSubviews {

	[super layoutSubviews];
	
	self.contentView.frame = self.bounds;
	self.busyOverlayView.frame = self.bounds;

}

@end
