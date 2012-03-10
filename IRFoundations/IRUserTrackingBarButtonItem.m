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
	BOOL isBlack = (self.barStyle == UIBarStyleBlackOpaque) || ((self.barStyle == UIBarStyleBlack) && !self.translucent);
	BOOL isBlackTranslucent = (self.barStyle == UIBarStyleBlackTranslucent) || ((self.barStyle == UIBarStyleBlack) && self.translucent);
	BOOL isLandscapePhone = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone);
	
	UIEdgeInsets const landscapePhoneImageInsets = (UIEdgeInsets){ 12, 4, 12, 4 };
	UIEdgeInsets const imageInsets = (UIEdgeInsets){ 15, 5, 15, 5 };
	
	UIImage * (^image)(NSString *, UIEdgeInsets) = ^ (NSString *name, UIEdgeInsets insets) {
		return [IRUIKitImage(name) resizableImageWithCapInsets:insets];
	};
	
	void (^setImage)(UIImage *, UIControlState) = ^ (UIImage *image, UIControlState state) {
		[self.trackingButton setBackgroundImage:image forState:state];
	};
	
	setImage(
		isDefault ? isLandscapePhone ?
			image(@"UINavigationBarMiniDefaultButton", landscapePhoneImageInsets) :
			image(@"UINavigationBarDefaultButton", imageInsets) :
		isBlack ? isLandscapePhone ?
			image(@"UINavigationBarMiniBlackOpaqueButton", landscapePhoneImageInsets) :
			image(@"UINavigationBarBlackOpaqueButton", imageInsets) :
		isBlackTranslucent ? isLandscapePhone ?
			image(@"UINavigationBarMiniBlackTranslucentButtonPressed", landscapePhoneImageInsets) :
			image(@"UINavigationBarBlackTranslucentButtonPressed", imageInsets) :
		nil,
		UIControlStateNormal
	);
	
	setImage(
		isDefault ? isLandscapePhone ?
			image(@"UINavigationBarMiniDoneButton", landscapePhoneImageInsets) :
			image(@"UINavigationBarDoneButtonPressed", imageInsets) :
		isBlack ? isLandscapePhone ?
			image(@"UINavigationBarMiniBlackOpaqueButtonPressed", landscapePhoneImageInsets) :
			image(@"UINavigationBarBlackOpaqueButtonPressed", imageInsets) :
		isBlackTranslucent ? isLandscapePhone ?
			image(@"UINavigationBarMiniBlackTranslucentButton", landscapePhoneImageInsets) :
			image(@"UINavigationBarBlackTranslucentButton", imageInsets) :
		nil,
		UIControlStateSelected
	);
	
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

			//	TBD: animation
			
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
