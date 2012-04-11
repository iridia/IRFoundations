//
//  IRBusyView.m
//  IRFoundations
//
//  Created by Evadne Wu on 3/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRBusyView.h"
#import "IRActivityIndicatorView.h"

#import "IRBindings.h"
#import "CGGeometry+IRAdditions.h"

@implementation IRBusyView

@synthesize contentView, busyOverlayView, style, busy;

+ (IRBusyView *) wrappedBusyViewForView:(UIView *)wrappedView withStyle:(IRBusyViewStyle)aStyle {

	IRBusyView *returnedView = [[self alloc] initWithFrame:CGRectZero];
	if (!returnedView) return nil;
	
	returnedView.contentView = wrappedView;
	returnedView.style = aStyle;
	returnedView.busy = NO;
	
	[returnedView configureForPresetStyle:aStyle];
	[returnedView setNeedsLayout];
	
	return returnedView;

}

- (void) configureForPresetStyle:(IRBusyViewStyle)aStyle {

	switch (self.style) {
	
		case IRBusyViewStyleDefaultSpinner: {
		
			IRActivityIndicatorView *activityIndicator = [[IRActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
			activityIndicator.hidesWhenStopped = YES;	
			activityIndicator.animating = NO;
			activityIndicator.userInteractionEnabled = NO;
			
			[activityIndicator irBind:@"hidden" toObject:self keyPath:@"busy" options:[NSDictionary dictionaryWithObjectsAndKeys:
			
				[ ^ (id inOldValue, id inNewValue, NSString *changeKind) {
				
					return [NSNumber numberWithBool:![inNewValue boolValue]];
				
				} copy], kIRBindingsValueTransformerBlock,
				
				[NSNumber numberWithBool:YES], kIRBindingsAssignOnMainThreadOption,
			
			nil]];
			
			[activityIndicator irBind:@"animating" toObject:self keyPath:@"busy" options:[NSDictionary dictionaryWithObjectsAndKeys:
			
				[NSNumber numberWithBool:YES], kIRBindingsAssignOnMainThreadOption,
			
			nil]];

			[self.contentView irBind:@"hidden" toObject:self keyPath:@"busy" options:[NSDictionary dictionaryWithObjectsAndKeys:
			
				[NSNumber numberWithBool:YES], kIRBindingsAssignOnMainThreadOption,
			
			nil]];
						
			self.busyOverlayView = activityIndicator;
			
			break;
		
		}
		
		default: {
			
			NSParameterAssert(NO);
			break;
			
		}
	
	}

}

- (void) setContentView:(UIView *)aView {

	if (contentView == aView)
	return;

	[contentView removeFromSuperview];
	contentView = aView;
	[self addSubview:contentView];
	
	[self setNeedsLayout];

}

- (void) setBusyOverlayView:(UIView *)aView {

	if (busyOverlayView == aView)
	return;

	[busyOverlayView removeFromSuperview];
	busyOverlayView = aView;
	[self addSubview:busyOverlayView];
	[self bringSubviewToFront:busyOverlayView];
	
	[self setNeedsLayout];

}

- (void) layoutSubviews {

	[super layoutSubviews];
	
	self.contentView.center = irCGRectGetCenterOfRectBounds(self.bounds);
	self.busyOverlayView.center = irCGRectGetCenterOfRectBounds(self.bounds);

}

@end
