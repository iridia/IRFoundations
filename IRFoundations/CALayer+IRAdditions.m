//
//  CALayer+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 9/6/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "CALayer+IRAdditions.h"

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

- (UIImage *) irRenderedImage {

	UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
	CGContextRef bitmapContext = UIGraphicsGetCurrentContext();
	[self renderInContext:bitmapContext];
	UIImage *returnedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return returnedImage;

}

@end
