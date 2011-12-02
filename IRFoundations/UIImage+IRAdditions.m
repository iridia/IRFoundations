//
//  UIImage+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 6/16/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <libkern/OSAtomic.h>
#import <objc/runtime.h>

#import "UIImage+IRAdditions.h"
#import "IRShadow.h"

static NSString * const kUIImageIRAdditionsRepresentedObject = @"kUIImageIRAdditionsRepresentedObject";

static void __attribute__((constructor)) initialize() {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	if ([[[UIDevice currentDevice] systemVersion] localizedCompare:@"5.0"] == NSOrderedAscending) {
		Class class = [UIImage class];

		if (!class_addMethod(
			class,
			@selector(initWithCoder:), class_getMethodImplementation(class, @selector(_irInitWithCoder:)),
			protocol_getMethodDescription(@protocol(NSCoding), @selector(initWithCoder:), YES, YES).types
		)) {
			NSLog(@"Error swizzling -[UIImage initWithCoder:] off.  Expect mayhem.");
		}

		if (!class_addMethod(
			class, 
			@selector(encodeWithCoder:),
			class_getMethodImplementation(class, @selector(_irEncodeWithCoder:)), 
			protocol_getMethodDescription(@protocol(NSCoding), @selector(encodeWithCoder:), YES, YES).types)
		) {
			NSLog(@"Error swizzling -[UIImage encodeWithCoder:] off.  Expect mayhem.");
		}

	}
	
	[pool drain];
	
}


@implementation UIImage (IRAdditions)

- (id) _irInitWithCoder:(NSCoder *)decoder {
	NSLog(@"%s: shouldn’t have been called, swizzling anyway.", __FUNCTION__);
	return nil;
}

- (void) _irEncodeWithCoder:(NSCoder *)aCoder {
	NSLog(@"%s: shouldn’t have been called, swizzling anyway.", __FUNCTION__);
}

- (UIImage *) irStandardImage {

	if (self.imageOrientation == UIImageOrientationUp)
	return self;

	UIGraphicsBeginImageContext(self.size);
	[self drawAtPoint:CGPointZero];
	
	return UIGraphicsGetImageFromCurrentImageContext();

}

- (UIImage *) irDecodedImage {

	CGImageRef cgImage = [self CGImage]; 
	size_t width = CGImageGetWidth(cgImage);
	size_t height = CGImageGetHeight(cgImage);
	
	if (!width && !height)
		return self;
		
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(
		NULL, 
		width, 
		height, 8, 
		width * 4, 
		colorSpace,
		kCGImageAlphaNoneSkipFirst
	);
	
	NSParameterAssert(context);
	
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);

	return self;

}

- (UIImage *) irScaledImageWithSize:(CGSize)aSize {

	if (CGSizeEqualToSize(aSize, CGSizeZero))
		return self;

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, aSize.width, aSize.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
	
	CGContextClearRect(context, (CGRect){ CGPointZero, aSize });
	CGContextDrawImage(context, (CGRect){ CGPointZero, aSize }, self.CGImage);
	CGImageRef scaledImage = CGBitmapContextCreateImage(context);
	
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(context);
	UIImage *image = [UIImage imageWithCGImage: scaledImage];
	CGImageRelease(scaledImage);
	
	return image;

}

- (UIImage *) irSolidImageWithFillColor:(UIColor *)fillColor shadow:(IRShadow *)shadowOrNil {

	NSParameterAssert(fillColor);
	
	CGRect contextRect = (CGRect){ CGPointZero, self.size };
	CGPoint imageOffset = CGPointZero;
	
	if (shadowOrNil) {
		
		CGRect spillRect = CGRectInset(
			CGRectOffset(
				(CGRect){ CGPointZero, self.size }, 
				shadowOrNil.offset.width, 
				shadowOrNil.offset.height
			),
			-1 * shadowOrNil.spread,
			-1 * shadowOrNil.spread
		);
		
		contextRect = CGRectUnion(contextRect, spillRect);
		imageOffset = (CGPoint){
			spillRect.origin.x + shadowOrNil.spread,
			spillRect.origin.y + shadowOrNil.spread
		};
		contextRect.origin = CGPointZero;
		
	}
	
	
	UIGraphicsBeginImageContextWithOptions(contextRect.size, NO, 0.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (shadowOrNil)
		CGContextSetShadowWithColor(context, shadowOrNil.offset, shadowOrNil.spread, shadowOrNil.color.CGColor);
	
	CGContextSaveGState(context);
	CGContextConcatCTM(context, (CGAffineTransform){ 1, 0, 0, -1, 0, contextRect.size.height });

	CGContextConcatCTM(context, CGAffineTransformMakeTranslation(
		-1 * imageOffset.x,
		-1 * (contextRect.size.height - imageOffset.y - self.size.height) //imageOffset.y
	));
	
	CGContextBeginTransparencyLayer(context, nil);
	CGContextClipToMask(context, (CGRect){ imageOffset, self.size }, self.CGImage);
	CGContextSetFillColorWithColor(context, fillColor.CGColor);
	CGContextFillRect(context, contextRect);
	
	CGContextEndTransparencyLayer(context);
	
	CGContextSaveGState(context);

	UIImage *returnedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return returnedImage;

}

- (id) irRepresentedObject {

	return objc_getAssociatedObject(self, &kUIImageIRAdditionsRepresentedObject);

}

- (void) irSetRepresentedObject:(id)newObject {

	if (self.irRepresentedObject == newObject)
		return;
	
	[self willChangeValueForKey:@"irRepresentedObject"];

	objc_setAssociatedObject(self, &kUIImageIRAdditionsRepresentedObject, newObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	[self didChangeValueForKey:@"irRepresentedObject"];

}

@end
