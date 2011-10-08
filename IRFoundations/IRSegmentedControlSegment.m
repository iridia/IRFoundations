//
//  IRSegmentedControlSegment.m
//  IRFoundations
//
//  Created by Evadne Wu on 12/1/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import "IRSegmentedControlSegment.h"


@interface IRSegmentedControlSegment ()

@property (nonatomic, readwrite, retain) UIImageView *imageView;
@property (nonatomic, readwrite, retain) UIImageView *highlightedImageView;
@property (nonatomic, readwrite, retain) UIImageView *backdropImageView;

@property (nonatomic, readwrite, assign) id trackingButtonTarget;
@property (nonatomic, readwrite, assign) SEL trackingButtonAction;

@end

@implementation IRSegmentedControlSegment

@synthesize delegate, trackingButton;
@synthesize image, highlightedImage, activeBackdropImage;
@synthesize alternateImage, alternateHighlightedImage;
@synthesize active, highlighted, usesAlternateImages;
@synthesize imageView, highlightedImageView, backdropImageView;
@synthesize trackingButtonTarget, trackingButtonAction;

- (id) initWithFrame:(CGRect)inFrame image:(UIImage *)inImage highlightedImage:(UIImage *)inHighlightedImage activeBackdrop:(UIImage *)inActiveBackdrop {

	self = [super initWithFrame:inFrame]; if (!self) return nil;
	
	self.trackingButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.trackingButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.trackingButton.frame = self.bounds;
	[self.trackingButton addTarget:self action:@selector(handleTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];	
	
	self.image = inImage;
	self.imageView = [[[UIImageView alloc] initWithImage:self.image] autorelease];
	self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.imageView.contentMode = UIViewContentModeCenter;
	self.imageView.frame = self.bounds;
	
	self.highlightedImage = inHighlightedImage;
	self.highlightedImageView = [[[UIImageView alloc] initWithImage:self.highlightedImage] autorelease];
	self.highlightedImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.highlightedImageView.contentMode = UIViewContentModeCenter;
	self.highlightedImageView.frame = self.bounds;

	self.activeBackdropImage = inActiveBackdrop;
	self.backdropImageView = [[[UIImageView alloc] initWithImage:self.activeBackdropImage] autorelease];
	self.backdropImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.backdropImageView.contentMode = UIViewContentModeLeft;
	self.backdropImageView.frame = self.bounds;

//	This is FUBAR, shall be fixed.	
	[self insertSubview:self.trackingButton atIndex:0];
	[self insertSubview:self.imageView atIndex:128];
	[self insertSubview:self.highlightedImageView atIndex:128];
	[self insertSubview:self.backdropImageView belowSubview:self.imageView];

	self.active = NO;	
	self.highlighted = NO;
	
	[self transition];
	
	return self;

}

- (void) handleTouchUpInside:(id)sender {

//	Perhaps this will be necessary…
//	if (self.active) return;

	[self.delegate handleSegmentTap:self];
//	[self.trackingButton addTarget:self action:@selector(handleTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];	
	
	[self transition];

}

- (void) setTrackingButtonTarget:(id)inTarget action:(SEL)inAction {

	if ((self.trackingButtonTarget != nil) && (self.trackingButtonAction != nil))
	[self.trackingButton removeTarget:self.trackingButtonTarget action:self.trackingButtonAction forControlEvents:UIControlEventTouchUpInside];
	
	self.trackingButtonTarget = nil;
	self.trackingButtonAction = nil;
	
	if (!inTarget || !inAction) return;
	
	self.trackingButtonTarget = inTarget;
	self.trackingButtonAction = inAction;
	
	[self.trackingButton addTarget:self.trackingButtonTarget action:self.trackingButtonAction forControlEvents:UIControlEventTouchUpInside];

}

- (void) setActive:(BOOL)inActive {

	[self setActive:inActive animated:YES];

}

- (void) setActive:(BOOL)inActive animated:(BOOL)inAnimated {

	if (self.active == inActive) return;
	
	active = inActive;
	
	[self transitionAnimated:inAnimated];

}

- (void) setHighlighted:(BOOL)inHighlighted {

	[self setHighlighted:inHighlighted animated:YES];

}

- (void) setHighlighted:(BOOL)inToggled animated:(BOOL)inAnimated {

	if (self.highlighted == inToggled) return;

	highlighted = inToggled;
	
	[self transitionAnimated:inAnimated];

}

- (void) setUsesAlternateImages:(BOOL)inUseAlternateImages {

	if (self.usesAlternateImages == inUseAlternateImages) return;

	usesAlternateImages = inUseAlternateImages;
	
	[self bestowImages];

}

- (void) transition {

	[self transitionAnimated:YES];

}

- (void) transitionAnimated:(BOOL)inAnimated {
	
	[UIView animateWithDuration:0.05 animations: ^ {
		
		self.imageView.alpha = self.highlighted ? 0 : 1;
		self.highlightedImageView.alpha = self.highlighted ? 1 : 0;
		self.backdropImageView.alpha = self.active ? 1 : 0;
	
	}];

}

- (void) bestowImages {

	self.imageView.image = (self.usesAlternateImages && self.alternateImage) ? self.alternateImage : self.image;
	self.highlightedImageView.image = (self.usesAlternateImages && self.alternateHighlightedImage) ? self.alternateHighlightedImage : self.highlightedImage;

}

@end
