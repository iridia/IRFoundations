//
//  IRPageCurlBarButtonItem.m
//  vibe
//
//  Created by Evadne Wu on 3/9/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRPageCurlBarButtonItem.h"
#import "UIKit+IRAdditions.h"

@implementation IRPageCurlBarButtonItem

- (void) awakeFromNib {

	[super awakeFromNib];
	
	[self setBackgroundImage:IRUIKitImage(@"UIButtonBarPageCurlDefault") forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	
	[self setBackgroundImage:IRUIKitImage(@"UIButtonBarPageCurlDefaultLandscape") forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
	
	[self setBackgroundImage:IRUIKitImage(@"UIButtonBarPageCurlSelected") forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
	
	[self setBackgroundImage:IRUIKitImage(@"UIButtonBarPageCurlSelectedLandscape") forState:UIControlStateSelected barMetrics:UIBarMetricsLandscapePhone];
	
	[self setBackgroundImage:IRUIKitImage(@"UIButtonBarPageCurlSelectedDown") forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	
	[self setBackgroundImage:IRUIKitImage(@"UIButtonBarPageCurlSelectedDownLandscape") forState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone];

	//	Force background display
	self.image = nil;
	self.title = @" ";

}

@end
