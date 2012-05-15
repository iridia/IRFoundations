//
//  IRPageCurlBarButtonItem.m
//  vibe
//
//  Created by Evadne Wu on 3/9/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRPageCurlBarButtonItem.h"
#import "UIKit+IRAdditions.h"


@interface IRPageCurlBarButtonItem ()
- (void) updateBackgroundImage;
@end


@implementation IRPageCurlBarButtonItem
@synthesize barStyle, translucent, selected;

- (void) awakeFromNib {

	[super awakeFromNib];
	
	self.barStyle = UIBarStyleDefault;
	self.translucent = NO;
	self.selected = NO;
	
	//	Force background display
	self.image = nil;
	self.title = @" ";
	
	[self updateBackgroundImage];

}

- (void) setBarStyle:(UIBarStyle)newBarStyle {

	if (barStyle == newBarStyle)
		return;
	
	barStyle = newBarStyle;
	
	[self updateBackgroundImage];

}

- (void) setTranslucent:(BOOL)newTranslucent {

	if (translucent == newTranslucent)
		return;
	
	translucent = newTranslucent;
	
	[self updateBackgroundImage];

}

- (void) setSelected:(BOOL) newSelected {

	if (selected == newSelected)
		return;
	
	selected = newSelected;
	
	[self updateBackgroundImage];

}

- (void) updateBackgroundImage {

	BOOL isDefault = (self.barStyle == UIBarStyleDefault);
	BOOL isBlack = (self.barStyle == UIBarStyleBlackOpaque) || ((self.barStyle == UIBarStyleBlack) && !self.translucent);
	BOOL isBlackTranslucent = (self.barStyle == UIBarStyleBlackTranslucent) || ((self.barStyle == UIBarStyleBlack) && self.translucent);
		
	void (^setImage)(NSString *name, UIControlState, UIBarMetrics) = ^ (NSString *name, UIControlState state, UIBarMetrics metrics) {
		[self setBackgroundImage:(name ? IRUIKitImage(name) : nil) forState:state barMetrics:metrics];
	};
	
	if (self.selected) {
	
		setImage(@"UIButtonBarPageCurlSelected", UIControlStateNormal, UIBarMetricsDefault);
		setImage(@"UIButtonBarPageCurlSelectedLandscape", UIControlStateNormal, UIBarMetricsLandscapePhone);
		
		setImage(@"UIButtonBarPageCurlSelectedDown", UIControlStateHighlighted, UIBarMetricsDefault);
		setImage(@"UIButtonBarPageCurlSelectedDownLandscape", UIControlStateHighlighted, UIBarMetricsLandscapePhone);
		
	} else {
	
		setImage((
			isDefault ?
				@"UIButtonBarPageCurlDefault" :
			isBlack ?
				@"UIButtonBarPageCurlBlackOpaque" :
			isBlackTranslucent ?
				@"UIButtonBarPageCurlBlackTranslucent" : 
			nil
		), UIControlStateNormal, UIBarMetricsDefault);
		
		setImage((
			isDefault ?
				@"UIButtonBarPageCurlDefaultLandscape" :
			isBlack ?
				@"UIButtonBarPageCurlBlackOpaqueLandscape" :
			isBlackTranslucent ?
				@"UIButtonBarPageCurlBlackTranslucentLandscape" :
			nil
		), UIControlStateNormal, UIBarMetricsLandscapePhone);
		
		setImage(nil, UIControlStateHighlighted, UIBarMetricsDefault);
		setImage(nil, UIControlStateHighlighted, UIBarMetricsLandscapePhone);
			
	}
	
}

@end
