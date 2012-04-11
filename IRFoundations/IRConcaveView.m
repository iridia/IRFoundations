//
//  IRConcaveView.m
//  IRFoundations
//
//  Created by Evadne Wu on 1/29/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRConcaveView.h"


@interface IRConcaveView ()

- (void) irConfigure;

@end

@implementation IRConcaveView

@synthesize innerShadow;

- (id) initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if (!self) return nil;
	
	[self irConfigure];
	
	return self;

}

- (id) initWithCoder:(NSCoder *)aDecoder {

	self = [super initWithCoder:aDecoder];
	if (!self) return nil;
	
	[self irConfigure];
	
	return self;

}

- (void) irConfigure {

	self.opaque = NO;
	self.innerShadow = [IRShadow shadowWithColor:[UIColor colorWithWhite:0 alpha:1] offset:CGSizeMake(0, 1) spread:6 edgeInsets:UIEdgeInsetsMake(-1, -1, -1, -1)];

}

- (void) drawRect:(CGRect)rect {

	CGContextRef context = UIGraphicsGetCurrentContext();

	if (self.innerShadow) {
		
		CGContextSaveGState(context);

		CGPathRef offsetPathRef = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(CGRectInset(
		
			self.bounds, 
			(-.5 * self.innerShadow.spread), 
			(-.5 * self.innerShadow.spread)
			
		), self.innerShadow.edgeInsets) cornerRadius:(CGFloat)(self.layer.cornerRadius * sqrt(1.5))].CGPath;
		
		CGContextSetStrokeColorWithColor(context, self.innerShadow.color.CGColor);
		CGContextSetShadowWithColor(context, self.innerShadow.offset, self.innerShadow.spread, self.innerShadow.color.CGColor);
		CGContextSetLineWidth(context, self.innerShadow.spread);
		
		CGContextAddPath(context, offsetPathRef);
		CGContextStrokePath(context);

		CGContextRestoreGState(context);
	
	}

}

@end
