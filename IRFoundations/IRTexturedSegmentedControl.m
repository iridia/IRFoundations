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
	
	UIImage * (^stitchX)(NSArray *) = ^ (NSArray *images) {
		
		CGSize imageSize = CGSizeZero;
		CGFloat offsetX = 0;
		
		for (UIImage *image in images) {
			imageSize.width += image.size.width;
			imageSize.height = image.size.height;
		}
		
		UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
		
		for (UIImage *image in images) {
			[image drawAtPoint:(CGPoint){ offsetX, 0 }];
			offsetX += image.size.width;
		}
		
		UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return image;
		
	};
	
	NSArray * (^repeatMid)(NSArray *) = ^ (NSArray *originalArray){
		
		NSMutableArray *returnedArray = [NSMutableArray array];
		
		[originalArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			
			[returnedArray addObject:obj];
			
			if ((idx != 0) && (idx != ([originalArray count] - 1))) {
			
				for (int i = 0; i < 8; i++)
					[returnedArray addObject:obj];
			
			}
			
		}];
		
		return returnedArray;
		
	};

	//	TBD: Cache this stuff.

	[self setBackgroundImage:[stitchX(repeatMid([NSArray arrayWithObjects:
		IRUIKitImage(@"UISegmentTexturedButtonSelectedLeftCap"),
		IRUIKitImage(@"UISegmentTexturedButtonSelectedCenter"),
		IRUIKitImage(@"UISegmentTexturedButtonSelectedRightCap"),
	nil])) resizableImageWithCapInsets:(UIEdgeInsets){ 0, 16, 1, 16 }] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
	
	[self setBackgroundImage:[stitchX(repeatMid([NSArray arrayWithObjects:
		IRUIKitImage(@"UISegmentTexturedButtonHighlightedLeftCap"),
		IRUIKitImage(@"UISegmentTexturedButtonHighlightedCenter"),
		IRUIKitImage(@"UISegmentTexturedButtonHighlightedRightCap"),
	nil])) resizableImageWithCapInsets:(UIEdgeInsets){ 0, 16, 1, 16 }] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	
	[self setBackgroundImage:[stitchX(repeatMid([NSArray arrayWithObjects:
		IRUIKitImage(@"UISegmentTexturedButtonSelectedHighlightedLeftCap"),
		IRUIKitImage(@"UISegmentTexturedButtonSelectedHighlightedCenter"),
		IRUIKitImage(@"UISegmentTexturedButtonSelectedHighlightedRightCap"),
	nil])) resizableImageWithCapInsets:(UIEdgeInsets){ 0, 16, 1, 16 }] forState:UIControlStateSelected|UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
		
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
