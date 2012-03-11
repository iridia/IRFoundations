//
//  IRTexturedSegmentedControl.m
//  IRFoundations
//
//  Created by Evadne Wu on 3/12/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRTexturedSegmentedControl.h"
#import "UIKit+IRAdditions.h"

@implementation IRTexturedSegmentedControl

- (void) awakeFromNib {

	[super awakeFromNib];
	
	[self setBackgroundImage:[IRUIKitImage(@"UITexturedButton") resizableImageWithCapInsets:(UIEdgeInsets){ 0, 16, 1, 16 }] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	
//	[self setBackgroundImage:[IRUIKitImage(@"UITexturedPressedButton") resizableImageWithCapInsets:(UIEdgeInsets){ 0, 16, 1, 16 }] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
//
//	[self setBackgroundImage:[IRUIKitImage(@"UITexturedPressedButton") resizableImageWithCapInsets:(UIEdgeInsets){ 0, 16, 1, 16 }] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

	UIImage *selectedLeftCap = IRUIKitImage(@"UISegmentTexturedButtonSelectedLeftCap");
	UIImage *selectedCenter = IRUIKitImage(@"UISegmentTexturedButtonSelectedCenter");	
	UIImage *selectedRightCap = IRUIKitImage(@"UISegmentTexturedButtonSelectedRightCap");	
		
	UIGraphicsBeginImageContextWithOptions((CGSize){
		selectedLeftCap.size.width + selectedCenter.size.width + selectedRightCap.size.width,
		selectedCenter.size.width
	}, NO, selectedCenter.scale);
	
	[selectedLeftCap drawAtPoint:CGPointZero];
	[selectedCenter drawAtPoint:(CGPoint){ selectedLeftCap.size.width, 0 }];
	[selectedRightCap drawAtPoint:(CGPoint){ selectedLeftCap.size.width + selectedCenter.size.width, 0 }];
	
	UIImage *selectedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	//	Probably cache them
	
	//	UIImage *highlightedLeftCap = IRUIKitImage(@"UISegmentTexturedButtonHighlightedLeftCap");
	//	UIImage *highlightedCenter = IRUIKitImage(@"UISegmentTexturedButtonHighlightedCenter");	
	//	UIImage *highlightedRightCap = IRUIKitImage(@"UISegmentTexturedButtonHighlightedRightCap");	
	//	
	//	UIImage *selectedHighlightedLeftCap = IRUIKitImage(@"UISegmentTexturedButtonSelectedHighlightedLeftCap");
	//	UIImage *selectedHighlightedCenter = IRUIKitImage(@"UISegmentTexturedButtonSelectedHighlightedCenter");	
	//	UIImage *selectedHighlightedRightCap = IRUIKitImage(@"UISegmentTexturedButtonSelectedHighlightedRightCap");	
	
	[self setBackgroundImage:selectedImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];

	
	self.bounds = (CGRect){
		CGPointZero,
		(CGSize){
			CGRectGetWidth(self.bounds),
			[self sizeThatFits:self.bounds.size].height
		}
	};
	
	self.tintColor = [UIColor clearColor];
	
//	[self setBackgroundImage:IRUIKitImage(@"UISegmentTexturedButtonHighlightedCenter") forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
//
//	[self setBackgroundImage:IRUIKitImage(@"UISegmentTexturedButtonSelectedCenter") forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
//	
//	[self setBackgroundImage:IRUIKitImage(@"UISegmentTexturedButtonSelectedHighlightedCenter") forState:UIControlStateSelected|UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
//	

	[self setDividerImage:IRUIKitImage(@"UISegmentTexturedDivider") forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	
	[self setDividerImage:IRUIKitImage(@"UISegmentTexturedSelectedDivider") forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	
	[self setDividerImage:IRUIKitImage(@"UISegmentTexturedSelectedHighlightedDivider") forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
	
	[self layoutSubviews];

}

@end
