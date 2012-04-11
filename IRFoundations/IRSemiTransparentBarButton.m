//
//  MLSemiTransparentBarButton.m
//  IRFoundations
//
//  Created by Evadne Wu on 12/11/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import "IRSemiTransparentBarButton.h"





void CGContextAddRoundRect (CGContextRef context, CGRect rect, float radius) {

//	I can’t even figure this out without some ASCII art.
//	
//	  7 - 0
//	6       1
//	|       |
//	5       2
//	  4 - 3 
//	

	CGFloat coordX[4] = {rect.origin.x, rect.origin.x + radius, rect.origin.x + rect.size.width - radius, rect.origin.x + rect.size.width};
	CGFloat coordY[4] = {rect.origin.y, rect.origin.y + radius, rect.origin.y + rect.size.height - radius, rect.origin.y + rect.size.height};

	CGPoint points[8] = {
	
		CGPointMake(coordX[2], coordY[0]),
		CGPointMake(coordX[3], coordY[1]),
		CGPointMake(coordX[3], coordY[2]),
		CGPointMake(coordX[2], coordY[3]),
		CGPointMake(coordX[1], coordY[3]),
		CGPointMake(coordX[0], coordY[2]),
		CGPointMake(coordX[0], coordY[1]),
		CGPointMake(coordX[1], coordY[0])
		
	};
	
	CGContextBeginPath(context);

	CGContextMoveToPoint(context, points[0].x, points[0].y);
	CGContextAddArcToPoint(context, coordX[3], coordY[0], points[1].x, points[1].y, radius);
	CGContextAddArcToPoint(context, coordX[3], coordY[3], points[3].x, points[3].y, radius);
	CGContextAddArcToPoint(context, coordX[0], coordY[3], points[5].x, points[5].y, radius);
	CGContextAddArcToPoint(context, coordX[0], coordY[0], points[7].x, points[7].y, radius);
	CGContextAddLineToPoint(context, points[0].x, points[0].y);
		
	CGContextClosePath(context);

}





@interface IRSemiTransparentBarButton ()

- (void) configure;

@end

@implementation IRSemiTransparentBarButton

- (id) initWithCoder:(NSCoder *)aDecoder {

	self = [super initWithCoder:aDecoder];
	
	if (!self)
	return nil;
	
	[self configure];
	
	return self;

}

+ (id) buttonWithType:(UIButtonType)buttonType {

	IRSemiTransparentBarButton *button = [super buttonWithType:buttonType];
	if (!button) return nil;

	[button configure];
	
	return button;
	
}

- (void) configure {

	self.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
	self.titleLabel.shadowOffset = CGSizeMake(0, -1);
	
	[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self setTitleShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5] forState:UIControlStateNormal];
	
	self.opaque = NO;
	self.contentEdgeInsets = UIEdgeInsetsMake(7, 10, 8, 10);

}

- (void) setEnabled:(BOOL)inEnabled {

	[super setEnabled:inEnabled];
	
	[UIView animateWithDuration:0.25 animations: ^ {

		self.titleLabel.alpha = inEnabled ? 1.0 : 0.5;
		
	} completion: ^ (BOOL finished) {

		[self setNeedsDisplay];
		
	}];

}

- (void) setHighlighted:(BOOL)inHighlighted {

	[super setHighlighted:inHighlighted];
	
	[self setNeedsDisplay];

}





- (void) drawRect:(CGRect)rect {

	CGContextRef context = UIGraphicsGetCurrentContext();

	CGRect buttonVisualBounds = self.bounds;
	buttonVisualBounds.size.height -= 1;
	
	CGRect buttonStrokeBounds = buttonVisualBounds;
	buttonStrokeBounds.origin.x += 0.5;
	buttonStrokeBounds.origin.y += 0.5;
	buttonStrokeBounds.size.width -= 1;
	buttonStrokeBounds.size.height -= 1;
	
	CGRect buttonShadowBounds = buttonStrokeBounds;
	buttonShadowBounds.origin.y += 1;

	CGColorRef borderColor = [UIColor colorWithRed:88.0/255.0 green:43.0/255.0 blue:35.0/255.0 alpha:1.0].CGColor;
	CGColorRef disabledBorderColor = [UIColor colorWithRed:126.0/255.0 green:62.0/255.0 blue:50.0/255.0 alpha:1.0].CGColor;
	CGColorRef shadowColor = [UIColor colorWithWhite:1.0 alpha:0.4].CGColor;
	CGColorRef fillColor = [UIColor colorWithWhite:0.0 alpha:(self.highlighted ? 0.5 : 0.3)].CGColor;

	CGContextSetLineWidth(context, 1);
	
	if (self.enabled) {

		CGContextSaveGState(context);

		UIImage *tile = [UIImage imageNamed:@"MLTextureLeatherShaded"];
		CGRect tileRect = CGRectZero;
		tileRect.size = tile.size;
		tileRect.origin.y = -10;	//FIXME: Calculate instead of hardcode;

		CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
		CGContextScaleCTM(context, 1.0, -1.0);

		CGContextAddRoundRect(context, buttonVisualBounds, 4);
		CGContextClip(context);
		CGContextDrawTiledImage(context, tileRect, tile.CGImage);

		CGContextSetBlendMode(context, kCGBlendModeOverlay);

		CGContextAddRoundRect(context, buttonVisualBounds, 4);
		CGContextSetFillColorWithColor(context, fillColor);
		CGContextFillPath(context);

		CGContextRestoreGState(context);
	
	}

	CGContextAddRoundRect(context, buttonShadowBounds, 4);
	CGContextSetStrokeColorWithColor(context, shadowColor);
	CGContextStrokePath(context);

	CGContextAddRoundRect(context, buttonStrokeBounds, 4);
	CGContextSetStrokeColorWithColor(context, (self.enabled ? borderColor : disabledBorderColor));
	CGContextStrokePath(context);
	
}

@end
