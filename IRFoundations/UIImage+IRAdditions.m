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

static NSString * const kUIImage_IRAdditions_representedObject = @"kUIImageIRAdditionsRepresentedObject";
static NSString * const kUIImage_IRAdditions_didWriteToSavedPhotosCallback = @"UIImage_IRAdditions_didWriteToSavedPhotosCallback";

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

- (CGRect) irTransposedRectForSize:(CGSize)newSize {

	switch (self.imageOrientation) {
		
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			return (CGRect){
				CGPointZero,
				(CGSize){
					newSize.height,
					newSize.width
				}
			};

		default:
			return (CGRect){ CGPointZero, newSize };
		
	}
	
}

- (CGAffineTransform) irTransformForSize:(CGSize)newSize {
		
	CGAffineTransform transform = CGAffineTransformIdentity;

	switch (self.imageOrientation) {
		
		case UIImageOrientationDown:             // EXIF = 3
		case UIImageOrientationDownMirrored: {   // EXIF = 4
			transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
		}

		case UIImageOrientationLeft:             // EXIF = 6
		case UIImageOrientationLeftMirrored: {   // EXIF = 5
			transform = CGAffineTransformTranslate(transform, newSize.width, 0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
		}

		case UIImageOrientationRight:           // EXIF = 8
		case UIImageOrientationRightMirrored: {  // EXIF = 7
			transform = CGAffineTransformTranslate(transform, 0, newSize.height);
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			break;
		}
		
		default: {
			break;
		}
		
	}

	switch (self.imageOrientation) {
	
		case UIImageOrientationUpMirrored:      // EXIF = 2
		case UIImageOrientationDownMirrored: {  // EXIF = 4
			transform = CGAffineTransformTranslate(transform, newSize.width, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
		}

		case UIImageOrientationLeftMirrored:    // EXIF = 5
		case UIImageOrientationRightMirrored: {  // EXIF = 7
			transform = CGAffineTransformTranslate(transform, newSize.height, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
		}
		
		default: {
			break;
		}
		
	}

	return transform;
	
}

- (UIImage *) irStandardImage {

	if (self.imageOrientation == UIImageOrientationUp)
	if (self.scale == 1)
		return self;

	UIGraphicsBeginImageContextWithOptions((CGSize){
		self.size.width * self.scale,
		self.size.height * self.scale
	}, NO, 1.0);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextScaleCTM(context, self.scale, self.scale);
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
	
	if (colorSpace) {
		
		CGContextRef context = CGBitmapContextCreate(
			NULL, 
			width, 
			height, 8, 
			width * 4, 
			colorSpace,
			kCGImageAlphaNoneSkipFirst
		);
			
		if (context) {
			
			CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
			CGContextRelease(context);
		
		}

		CGColorSpaceRelease(colorSpace);
	
	}

	return self;

}

- (UIImage *) irScaledImageWithSize:(CGSize)aSize {

	if (CGSizeEqualToSize(aSize, CGSizeZero))
		return self;
	
	CGImageRef const ownImage = self.CGImage;
	UIImageOrientation const ownOrientation = self.imageOrientation;
	CGSize const drawnPixelSize = (CGSize){ aSize.width * self.scale, aSize.height * self.scale };
	
	CGAffineTransform const drawnTransform = [self irTransformForSize:drawnPixelSize];
	CGRect const drawnRect = [self irTransposedRectForSize:drawnPixelSize];
	
	CGColorSpaceRef const colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef const context = CGBitmapContextCreate(NULL, drawnPixelSize.width, drawnPixelSize.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
	
	CGContextConcatCTM(context, drawnTransform);
	CGContextClearRect(context, drawnRect);
	CGContextDrawImage(context, drawnRect, self.CGImage);
	
	CGImageRef scaledImage = CGBitmapContextCreateImage(context);
	
	CGColorSpaceRelease(colorSpace);
	CGContextRelease(context);
	
	UIImage *image = [UIImage imageWithCGImage:scaledImage scale:self.scale orientation:UIImageOrientationUp];
	
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
		
		contextRect.size = spillRect.size;
		imageOffset = (CGPoint){
			0 - spillRect.origin.x,
			MAX(0, shadowOrNil.spread + shadowOrNil.offset.height)
		};

	}
	
	
	UIGraphicsBeginImageContextWithOptions(contextRect.size, NO, 0.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (shadowOrNil)
		CGContextSetShadowWithColor(context, shadowOrNil.offset, shadowOrNil.spread, shadowOrNil.color.CGColor);
	
	CGContextSaveGState(context);
	CGContextConcatCTM(context, (CGAffineTransform){ 1, 0, 0, -1, 0, contextRect.size.height });
	
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

	return objc_getAssociatedObject(self, &kUIImage_IRAdditions_representedObject);

}

- (void) irSetRepresentedObject:(id)newObject {

	if (self.irRepresentedObject == newObject)
		return;
	
	[self willChangeValueForKey:@"irRepresentedObject"];

	objc_setAssociatedObject(self, &kUIImage_IRAdditions_representedObject, newObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	[self didChangeValueForKey:@"irRepresentedObject"];

}

- (void) irWriteToSavedPhotosAlbumWithCompletion:(void(^)(BOOL didWrite, NSError *error))aBlock {

	__block NSDictionary *contextInfo = [[NSDictionary dictionaryWithObjectsAndKeys:
	
		[[ ^ (NSError *error) {
		
			if (aBlock)
				aBlock((BOOL)!error, error);
					
		} copy] autorelease], kUIImage_IRAdditions_didWriteToSavedPhotosCallback,
	
	nil] retain];

	UIImageWriteToSavedPhotosAlbum(self, self, @selector(handleDidWriteImageToSavedPhotosAlbum:withError:contextInfo:), contextInfo);

}

- (void) handleDidWriteImageToSavedPhotosAlbum:(UIImage *)image withError:(NSError *)error contextInfo:(NSDictionary *)contextInfo {

	void (^callback)(NSError *) = [contextInfo objectForKey:kUIImage_IRAdditions_didWriteToSavedPhotosCallback];
	
	if (callback)
		callback(error);
	
	if ([contextInfo isKindOfClass:[NSDictionary class]])	
		[contextInfo autorelease];

}

+ (BOOL) validateContentsOfFileAtPath:(NSString *)aFilePath error:(NSError **)error {

	if (!aFilePath)
		return YES;

	error = error ? error : &(NSError *){ nil };
	
	if (aFilePath && ![[NSFileManager defaultManager] fileExistsAtPath:aFilePath]) {
		
		*error = [NSError errorWithDomain:@"com.iridia.foundations" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
			[NSString stringWithFormat:@"Image at %@ is actually nonexistant", aFilePath], NSLocalizedDescriptionKey,
		nil]];
		
		return NO;
		
	} else if (![UIImage imageWithData:[NSData dataWithContentsOfMappedFile:aFilePath]]) {
		
		*error = [NSError errorWithDomain:@"com.iridia.foundations" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
			[NSString stringWithFormat:@"Image at %@ can’t be decoded", aFilePath], NSLocalizedDescriptionKey,
		nil]];
		
		return NO;
		
	}

	return YES;

}

@end
