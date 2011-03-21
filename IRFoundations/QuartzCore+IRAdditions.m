//
//  QuartzCore+IRAdditions.m
//  Milk
//
//  Created by Evadne Wu on 2/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "QuartzCore+IRAdditions.h"


void IRCATransact(void(^aBlock)(void)) {

	[CATransaction begin];
	[CATransaction setAnimationDuration:0.0];
	[CATransaction setDisableActions:YES];
	
	if (aBlock)
	aBlock();

	[CATransaction commit];

}





@implementation CALayer (IRAdditions)

+ (NSMutableDictionary *) irDefaultNoActionsDictionary {

	static NSMutableDictionary *returnedDictionary = nil;
	
	if (!returnedDictionary) {
	
		returnedDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		
			[NSNull null], @"onOrderIn",
			[NSNull null], @"onOrderOut",
			[NSNull null], @"sublayers",
			[NSNull null], @"contents",
			[NSNull null], @"hidden",
			[NSNull null], @"alpha",

			[NSNull null], @"frame",
			[NSNull null], @"position",
			[NSNull null], @"anchorPoint",
			[NSNull null], @"bounds",
			[NSNull null], @"transform",

		nil];
		
		[returnedDictionary retain];
	
	}
	
	return returnedDictionary;

}

- (void) irSetShadowColor:(UIColor *)color alpha:(CGFloat)alpha spread:(CGFloat)spread offset:(CGSize)offset {

	self.shadowColor = color.CGColor;
	self.shadowOpacity = alpha;
	self.shadowRadius = spread;
	self.shadowOffset = offset;
	
}

@end
