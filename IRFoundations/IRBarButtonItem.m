//
//  IRBarButtonItem.m
//  IRFoundations
//
//  Created by Evadne Wu on 3/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRBarButtonItem.h"


@implementation IRBarButtonItem

@synthesize block;

- (void) dealloc {

	[block release];
	
	[super dealloc];

}

+ (id) itemWithCustomView:(UIView *)aView {

	return [[[self alloc] initWithCustomView:aView] autorelease];

}

+ (id) itemWithSystemItem:(UIBarButtonSystemItem)aSystemItem wiredAction:(void(^)(IRBarButtonItem *senderItem))aBlock {

	IRBarButtonItem *returnedItem = [[self alloc] initWithBarButtonSystemItem:aSystemItem target:nil action:nil];
	if (!returnedItem) return nil;
	
	returnedItem.target = returnedItem;
	returnedItem.action = @selector(handleCustomButtonAction:);
	
	returnedItem.block = ^ { aBlock(returnedItem); };
	
	 return returnedItem; 

}

+ (id) itemWithButton:(UIButton *)aButton wiredAction:(void(^)(UIButton *senderButton, IRBarButtonItem *senderItem))aBlock {

	IRBarButtonItem *returnedItem = [self itemWithCustomView:aButton];
	if (!returnedItem) return nil;
	
	returnedItem.block = ^ { aBlock(aButton, returnedItem); };
	
	[aButton addTarget:returnedItem action:@selector(handleCustomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	
	return returnedItem;

}

+ (id) backItemWithTitle:(NSString *)aTitle tintColor:(UIColor *)aColor {

	IRBarButtonItem *returnedItem = [self itemWithButton:(( ^ {
	
		UIButton *returnedButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
		[returnedButton setImage:[[self class] backButtonImageWithTitle:aTitle font:nil backgroundColor:nil gradientColors:nil innerShadow:nil border:nil shadow:nil] forState:UIControlStateNormal];
		
		[returnedButton setImage:[[self class] backButtonImageWithTitle:aTitle font:nil backgroundColor:nil gradientColors:[NSArray arrayWithObjects:
		
		(id)[UIColor colorWithRed:1 green:1 blue:1 alpha:.75].CGColor,
		(id)[UIColor colorWithRed:.4 green:.4 blue:.4 alpha:.75].CGColor,
	
	nil] innerShadow:nil border:nil shadow:nil] forState:UIControlStateHighlighted];
		
	//	[returnedButton setAdjustsImageWhenHighlighted:NO];
		
		[returnedButton sizeToFit];
		
		return returnedButton;
	
	})()) wiredAction:nil];
	
	return returnedItem;

}

- (IBAction) handleCustomButtonAction:(id)sender {

	NSParameterAssert(self.block);
	self.block();

}





+ (UIImage *) backButtonImageWithTitle:(NSString *)aTitle font:(UIFont *)fontOrNil backgroundColor:(UIColor *)backgroundColorOrNil gradientColors:(NSArray *)backgroundGradientColorsOrNil innerShadow:(IRShadow *)innerShadowOrNil border:(IRBorder *)borderOrNil shadow:(IRShadow *)shadowOrNil {

	UIFont *usingFont = fontOrNil ? fontOrNil : [UIFont boldSystemFontOfSize:12.0f];
	UIColor *buttonBackgroundColor = backgroundColorOrNil ? backgroundColorOrNil : [UIColor colorWithWhite:0.35f alpha:1];
	IRShadow *buttonShadow = shadowOrNil ? shadowOrNil : [IRShadow shadowWithColor:[UIColor colorWithWhite:1 alpha:0.5] offset:(CGSize){ 0, 1 } spread:0.5];
	NSArray *buttonGradientColors = backgroundGradientColorsOrNil ? backgroundGradientColorsOrNil : [NSArray arrayWithObjects:
		
		(id)[UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor,
		(id)[UIColor colorWithRed:.4 green:.4 blue:.4 alpha:1].CGColor,
	
	nil];
	
	IRShadow *buttonInnerShadow = [IRShadow shadowWithColor:[UIColor colorWithWhite:0 alpha:0.5] offset:(CGSize){ 0, 1 } spread:2];
	IRBorder *buttonBorder = [IRBorder borderForEdge:IREdgeNone withType:IRBorderTypeInset width:1.0 color:[UIColor colorWithWhite:0.35 alpha:1]];
	
	static const UIEdgeInsets insets = (UIEdgeInsets){ 0, 12, 0, 8 };
	static const CGFloat cornerRadius = 6;
	static const CGFloat slopeSize = 2;
	static const CGFloat buttonHeight = 29.0;
	
	CGSize titleSize = [aTitle sizeWithFont:usingFont];
	CGSize finalSize = (CGSize){ titleSize.width + 20 + 8, 44.0f };

	UIGraphicsBeginImageContextWithOptions(finalSize, NO, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIBezierPath *bezierPath = (( ^ {
	
		UIBezierPath *bezierPath = [UIBezierPath bezierPath];
		
		[bezierPath moveToPoint:CGPointZero];
		
		[bezierPath addLineToPoint:(CGPoint){ insets.left - slopeSize, -1 * (0.5 * buttonHeight - slopeSize) }];
		
		[bezierPath addQuadCurveToPoint:(CGPoint){ insets.left + slopeSize, -1 * (0.5 * buttonHeight) }
		                   controlPoint:(CGPoint){ insets.left, -1 * (0.5 * buttonHeight) }];
		
		[bezierPath addLineToPoint:(CGPoint){ finalSize.width - insets.right - cornerRadius, -1 * (0.5 * buttonHeight) }];
		
		[bezierPath addQuadCurveToPoint:(CGPoint){ finalSize.width - insets.right, -1 * (0.5 * buttonHeight - cornerRadius) }
											 controlPoint:(CGPoint){ finalSize.width - insets.right, -1 * (0.5 * buttonHeight) }];
		
		[bezierPath addLineToPoint:(CGPoint){ finalSize.width - insets.right, 1 * (0.5 * buttonHeight - cornerRadius) }];
		
		[bezierPath addQuadCurveToPoint:(CGPoint){ finalSize.width - insets.right - cornerRadius, 1 * (0.5 * buttonHeight) }
											 controlPoint:(CGPoint){ finalSize.width - insets.right, 1 * (0.5 * buttonHeight) }];
		
		[bezierPath addLineToPoint:(CGPoint){ insets.left + slopeSize, 1 * (0.5 * buttonHeight) }];

		[bezierPath addQuadCurveToPoint:(CGPoint){ insets.left - slopeSize, 1 * (0.5 * buttonHeight - slopeSize) }
		                   controlPoint:(CGPoint){ insets.left, 1 * (0.5 * buttonHeight) }];
		
		[bezierPath addLineToPoint:CGPointZero];
		
		[bezierPath applyTransform:CGAffineTransformMakeTranslation(0, -0.5 + 0.5 * finalSize.height)];
		
		return bezierPath;
	
	})());
	
	if (buttonShadow) {
	
		CGContextSetShadowWithColor(context, buttonShadow.offset, buttonShadow.spread, buttonShadow.color.CGColor);
	
	}
	
	CGContextBeginTransparencyLayer(context, NULL);
	
	if (buttonBackgroundColor) {
	
		CGContextSaveGState(context);
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextSetFillColorWithColor(context, buttonBackgroundColor.CGColor);
		CGContextFillPath(context);
		CGContextRestoreGState(context);
	
	}
	
	if (buttonGradientColors) {
	
		CGContextSaveGState(context);
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextClip(context);
		CGGradientRef topGradient = CGGradientCreateWithColors(NULL, (CFArrayRef)buttonGradientColors, NULL);
		CGContextDrawLinearGradient(context, topGradient, CGPointZero, (CGPoint){ 0, floorf(1 * finalSize.height) }, 0);
		CGGradientRelease(topGradient);
		CGContextRestoreGState(context);
	
	}
	
	if (buttonInnerShadow) {
	
		CGContextSaveGState(context);
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextClip(context);
		CGContextSetStrokeColorWithColor(context, buttonInnerShadow.color.CGColor);
		CGContextSetLineWidth(context, buttonInnerShadow.spread);
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextSetShadowWithColor(context, buttonInnerShadow.offset, buttonInnerShadow.spread, buttonInnerShadow.color.CGColor);
		CGContextStrokePath(context);
		CGContextRestoreGState(context);
	
	}
	
	if (buttonBorder) {
	
		NSParameterAssert(buttonBorder.type == IRBorderTypeInset);
		
		CGContextSaveGState(context);
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextClip(context);
		CGContextSetStrokeColorWithColor(context, buttonBorder.color.CGColor);
		CGContextSetLineWidth(context, buttonBorder.width * 2);
		CGContextSetBlendMode(context, kCGBlendModeClear); // first clean underlying stuff
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextStrokePath(context);
		CGContextSetBlendMode(context, kCGBlendModeNormal); // then draw over a clear surface
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextStrokePath(context);
		CGContextRestoreGState(context);
	
	}
	
	if (aTitle) {
	
		CGContextSaveGState(context);
		CGContextSetShadowWithColor(context, (CGSize){ 0, 1 }, 0, [UIColor colorWithWhite:1 alpha:0.5].CGColor);
		CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.2 alpha:1].CGColor);
		CGRect titleRect = (CGRect){ (CGPoint){ insets.left + 2, floorf(0.5 * (finalSize.height - titleSize.height)) }, finalSize };
		[aTitle drawInRect:titleRect withFont:usingFont];
		CGContextRestoreGState(context);
	
	}
	
	CGContextEndTransparencyLayer(context);
	
	UIImage *returnedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return returnedImage;	

}

@end
