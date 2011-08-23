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

- (UIImage *) irDecodedImage {

	CGImageRef imageRef = [self CGImage];
	CGRect rect = CGRectMake(0.f, 0.f, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
	CGColorSpaceRef genericColorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef bitmapContext = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, 8, 4 * rect.size.width, genericColorSpace, kCGImageAlphaPremultipliedLast);	
	CGContextDrawImage(bitmapContext, rect, imageRef);
	CGImageRef decompressedImageRef = CGBitmapContextCreateImage(bitmapContext);
	UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef];
	
	NSParameterAssert(decompressedImage);
	
	CGColorSpaceRelease(genericColorSpace);
	CGImageRelease(decompressedImageRef);
	CGContextRelease(bitmapContext);

	return decompressedImage;

}

@end
