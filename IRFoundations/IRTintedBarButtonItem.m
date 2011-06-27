//
//  IRTintedBarButtonItem.m
//  BarButtonItemWithImageAndTitleTest
//
//  Created by Evadne Wu on 2/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRTintedBarButtonItem.h"


@implementation IRTintedBarButtonItem

@dynamic tintColor, customView;
@synthesize block;
@synthesize flashesMomentarily;

+ (IRTintedBarButtonItem *) itemWithImage:(UIImage *)image title:(NSString *)title block:(void(^)(void))block {

	if (!image && !title)
	return nil;
	
	UISegmentedControl *control = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:(
	
		image ? title ? [self contentImageWithImage:image title:title font:[UIFont boldSystemFontOfSize:12.0] textColor:[UIColor whiteColor] spacing:4.0] : image : title ? title : @" "
	
	)]] autorelease];
	
	control.segmentedControlStyle = UISegmentedControlStyleBar;
	control.momentary = YES;
	
	IRTintedBarButtonItem *returnedItem = [[[self alloc] initWithCustomView:control] autorelease];
	
	[control addTarget:returnedItem action:@selector(irHandleSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
	
	returnedItem.block = block;
	
	return returnedItem;

}





- (void) dealloc {

	[block release];

	[super dealloc];

}

- (UIColor *) tintColor {

	return self.customView.tintColor;

}

- (void) setTintColor:(UIColor *)aColor {

	self.customView.tintColor = aColor;

}

- (BOOL) flashesMomentarily {

	return flashesMomentarily;

}

- (void) setFlashesMomentarily:(BOOL)flag {

	flashesMomentarily = flag;

//	FIXME: when the shading is undesirable, try using a custom invisible button?
//	self.blockingButton.userInteractionEnabled = 

}

- (void) irHandleSegmentedControlValueChanged:(id)sender {

	if (self.block)
	self.block();
	
	if (self.target && self.action)
	[self.target performSelector:self.action];

}





+ (UIImage *) contentImageWithImage:(UIImage *)glyph title:(NSString *)title font:(UIFont *)font textColor:(UIColor *)color spacing:(CGFloat)glyphSpacing {

	CGSize glyphSize = glyph.size;
	CGSize titleSize = [title sizeWithFont:font];
	CGSize contextSize = (CGSize) { 
	
		(glyphSize.width + glyphSpacing + titleSize.width), 
		MAX(glyphSize.height, titleSize.height)
		
	};
	

	UIGraphicsBeginImageContextWithOptions(contextSize, NO, [UIScreen mainScreen].scale);
	
	[glyph drawInRect:(CGRect) {
	
		(CGPoint) { 0, floorf(0.5 * (contextSize.height - glyphSize.height)) },
		glyphSize
	
	}];
	
	[color set];

	[title drawInRect:(CGRect) {
	
		(CGPoint) { glyphSize.width + glyphSpacing, floorf(0.5 * (contextSize.height - titleSize.height)) },
		titleSize
	
	} withFont:font];
	
	return UIGraphicsGetImageFromCurrentImageContext();

}

@end
