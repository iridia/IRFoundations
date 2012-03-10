//
//  IRUserTrackingBarButtonItem.m
//  IRFoundations
//
//  Created by Evadne Wu on 3/10/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MapKit+IRAdditions.h"
#import "UIKit+IRAdditions.h"
#import "IRUserTrackingBarButtonItem.h"
#import "Foundation+IRAdditions.h"

@interface IRUserTrackingBarButtonItem ()

@property (nonatomic, readwrite, assign) MKUserTrackingMode trackingMode;
@property (nonatomic, readonly, retain) UIButton *trackingButton;

- (void) handleTrackingModeChangedFrom:(MKUserTrackingMode)fromMode to:(MKUserTrackingMode)toMode;
- (void) handleApplicationDidChangeStatusBarOrientation:(NSNotification *)note;

- (void) updateTrackingButton;

@end

@implementation IRUserTrackingBarButtonItem
@synthesize mapView, trackingButton, barStyle, translucent;
@dynamic trackingMode;

- (MKUserTrackingMode) trackingMode {

	if (!self.mapView)
		return MKUserTrackingModeNone;
	
	return self.mapView.userTrackingMode;

}

- (void) setTrackingMode:(MKUserTrackingMode)newTrackingMode {

	if (self.trackingMode == newTrackingMode)
		return;
	
	NSCParameterAssert(self.mapView);
	self.mapView.userTrackingMode = newTrackingMode;

}

+ (NSSet *) keyPathsForValuesAffectingTrackingMode {

	return [NSSet setWithObjects:
	
		@"mapView.userTrackingMode",
	
	nil];

}

- (id) initWithCoder:(NSCoder *)aDecoder {

	self = [super initWithCoder:aDecoder];
	if (!self)
		return nil;
	
	self.barStyle = UIBarStyleDefault;
	
	return self;

}

- (void) awakeFromNib {

	[super awakeFromNib];
	
	self.customView = self.trackingButton;
	self.barStyle = UIBarStyleDefault;
	
	__block __typeof__(self) nrSelf = self;
	
	[self irAddObserverBlock: ^ (id inOldValue, id inNewValue, NSKeyValueChange changeKind) {
	
		MKUserTrackingMode fromMode = MKUserTrackingModeNone, toMode = MKUserTrackingModeNone;
		[inOldValue getValue:&fromMode];
		[inNewValue getValue:&toMode];
		
		[nrSelf handleTrackingModeChangedFrom:fromMode to:toMode];
		
	} forKeyPath:@"trackingMode" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	
	[self handleApplicationDidChangeStatusBarOrientation:nil];
	
}

- (UIButton *) trackingButton {

	if (trackingButton)
		return trackingButton;
	
	trackingButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	
	[trackingButton addTarget:self action:@selector(handleTrackingButtonTap:) forControlEvents:UIControlEventTouchUpInside];
	
	return trackingButton;

}

- (void) handleTrackingButtonTap:(UIButton *)sender {

	switch (self.trackingMode) {
	
		case MKUserTrackingModeFollow: {
			self.trackingMode = MKUserTrackingModeFollowWithHeading;
			break;
		}
		
		case MKUserTrackingModeFollowWithHeading: {
			self.trackingMode = MKUserTrackingModeNone;
			break;			
		}
		
		case MKUserTrackingModeNone: {
			self.trackingMode = MKUserTrackingModeFollow;
			break;
		}
	
	}

}

- (void) handleApplicationDidChangeStatusBarOrientation:(NSNotification *)note {

	[self updateTrackingButton];

}

- (void) setBarStyle:(UIBarStyle)newBarStyle {

	if (barStyle == newBarStyle)
		return;
	
	barStyle = newBarStyle;
	
	[self updateTrackingButton];

}

- (void) setTranslucent:(BOOL)newTranslucent {

	if (translucent == newTranslucent)
		return;
	
	translucent = newTranslucent;
	
	[self updateTrackingButton];

}

- (void) updateTrackingButton {

	BOOL isDefault = (self.barStyle == UIBarStyleDefault);
	BOOL isBlack = (self.barStyle == UIBarStyleBlack) && !self.translucent;
	BOOL isBlackTranslucent = (self.barStyle == UIBarStyleBlack) && self.translucent;
	BOOL isLandscapePhone = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone);
	
	UIImage *normalImage, *highlightedImage, *selectedImage, *selectedHighlightedImage;
	
	UIEdgeInsets const landscapePhoneImageInsets = (UIEdgeInsets){ 12, 4, 12, 4 };
	UIEdgeInsets const imageInsets = (UIEdgeInsets){ 15, 5, 15, 5 };
	
	
	[self.trackingButton setBackgroundImage:normalImage forState:UIControlStateNormal];
	[self.trackingButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
	[self.trackingButton setBackgroundImage:selectedImage forState:UIControlStateSelected];
	[self.trackingButton setBackgroundImage:selectedHighlightedImage forState:UIControlStateSelected|UIControlStateHighlighted];
	
	if (!isLandscapePhone) {
	
		UIEdgeInsets insets = (UIEdgeInsets){ 15, 5, 15, 5 };
		
		[self.trackingButton setBackgroundImage:[IRUIKitImage(@"UINavigationBarDefaultButton") resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
		
		[self.trackingButton setBackgroundImage:[IRUIKitImage(@"UINavigationBarDefaultButtonPressed") resizableImageWithCapInsets:insets] forState:UIControlStateHighlighted];
	
		[self.trackingButton setBackgroundImage:[IRUIKitImage(@"UINavigationBarDoneButton") resizableImageWithCapInsets:insets] forState:UIControlStateSelected];
		
		[self.trackingButton setBackgroundImage:[IRUIKitImage(@"UINavigationBarDoneButtonPressed") resizableImageWithCapInsets:insets] forState:UIControlStateSelected|UIControlStateHighlighted];
	
	} else {
	
		UIEdgeInsets insets = (UIEdgeInsets){ 12, 4, 12, 4 };
		
		[self.trackingButton setBackgroundImage:[IRUIKitImage(@"UINavigationBarMiniDefaultButton") resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
		
		[self.trackingButton setBackgroundImage:[IRUIKitImage(@"UINavigationBarMiniDefaultButtonPressed") resizableImageWithCapInsets:insets] forState:UIControlStateHighlighted];
		
		[self.trackingButton setBackgroundImage:[IRUIKitImage(@"UINavigationBarMiniDoneButton") resizableImageWithCapInsets:insets] forState:UIControlStateSelected];
		
		[self.trackingButton setBackgroundImage:[IRUIKitImage(@"UINavigationBarMiniDefaultButtonPressed") resizableImageWithCapInsets:insets] forState:UIControlStateSelected|UIControlStateHighlighted];
	
	}
	
	[self.trackingButton sizeToFit];
	self.trackingButton.frame = (CGRect){
		CGPointZero,
		(CGSize){
			32,
			CGRectGetHeight(self.trackingButton.bounds)
		}
	};
	
}

- (void) handleTrackingModeChangedFrom:(MKUserTrackingMode)fromMode to:(MKUserTrackingMode)toMode {

	switch (toMode) {
		
		case MKUserTrackingModeFollow: {
		
			[self.trackingButton setImage:IRMapKitImage(@"TrackingLocation") forState:UIControlStateNormal];
			self.trackingButton.selected = YES;
			break;
			
		}
		
		case MKUserTrackingModeFollowWithHeading: {
			
			[self.trackingButton setImage:IRMapKitImage(@"TrackingHeading") forState:UIControlStateNormal];
			self.trackingButton.selected = YES;
			break;
		}
		
		case MKUserTrackingModeNone: {
			
			[self.trackingButton setImage:IRMapKitImage(@"TrackingLocation") forState:UIControlStateNormal];
			self.trackingButton.selected = NO;
			break;
			
		}
			
	}

}

@end
