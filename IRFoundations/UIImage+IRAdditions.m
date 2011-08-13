//
//  UIImage+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 6/16/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <libkern/OSAtomic.h>

#import "UIImage+IRAdditions.h"

@implementation UIImage (IRAdditions)

- (UIImage *) irStandardImage {

	if (self.imageOrientation == UIImageOrientationUp)
	return self;

	UIGraphicsBeginImageContext(self.size);
	[self drawAtPoint:CGPointZero];
	
	return UIGraphicsGetImageFromCurrentImageContext();

}

@end
