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

	@autoreleasepool {
    
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
	
	}
	
}


@implementation UIImage (IRAdditions)

- (id) _irInitWithCoder:(NSCoder *)decoder {
	
	NSLog(@"%s: shouldn’t have been called, swizzling anyway.", __FUNCTION__);
	return nil;
	
}

- (void) _irEncodeWithCoder:(NSCoder *)aCoder {
	
	NSLog(@"%s: shouldn’t have been called, swizzling anyway.", __FUNCTION__);
	
}

+ (UIImage *) irImageNamed:(NSString *)name inBundle:(NSBundle *)bundle {

	NSString *baseName = [name stringByDeletingPathExtension];
	NSString *type = [[name pathExtension] length] ? [name pathExtension] : @"png";
	NSString *scaleSuffix = [NSString stringWithFormat:@"@%0.0fx", [UIScreen mainScreen].scale];
	NSString *deviceSuffix = ((NSString * []){
		[UIUserInterfaceIdiomPad] = @"~ipad",
		[UIUserInterfaceIdiomPhone] = @"~iphone"
	})[[UIDevice currentDevice].userInterfaceIdiom];	
	
	__block NSString *foundPath = nil;
	
	[[NSArray arrayWithObjects:
		
		[[baseName stringByAppendingString:deviceSuffix] stringByAppendingString:scaleSuffix],	
		[baseName stringByAppendingString:deviceSuffix],
		[baseName stringByAppendingString:scaleSuffix],
		baseName,
	
	nil] enumerateObjectsUsingBlock: ^ (NSString *fileName, NSUInteger idx, BOOL *stop) {
	
		NSString *prospectivePath = [bundle pathForResource:fileName ofType:type];
		if (prospectivePath) {
		
			foundPath = prospectivePath;
			*stop = YES;
		
		}
		
	}];
	
	if (!foundPath)
		return nil;
	
	NSData *imageData = [NSData dataWithContentsOfMappedFile:foundPath];
	foundPath = nil;
	
	CGDataProviderRef providerRef = CGDataProviderCreateWithCFData((__bridge CFDataRef)imageData);
	CGImageRef imageRef = CGImageCreateWithPNGDataProvider(providerRef, NULL, NO, kCGRenderingIntentDefault);
	
	CGFloat scale = [UIScreen mainScreen].scale;
	UIImage *image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
		
	CGDataProviderRelease(providerRef);
	CGImageRelease(imageRef);
	
	return image;

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

	CGImageRef cgImage = self.CGImage;
	size_t width = CGImageGetWidth(cgImage);
	size_t height = CGImageGetHeight(cgImage);
	
	if (!width && !height)
		return self;
		
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace) {
		
		CGBitmapInfo const bitmapInfo = kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Little;
		CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, bitmapInfo);
		
		CGColorSpaceRelease(colorSpace);
		
		if (context) {
			
			CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
			CGImageRef outputImage = CGBitmapContextCreateImage(context);
			
			CGContextRelease(context);
			
			if (outputImage) {
				
				return [UIImage imageWithCGImage:outputImage];	//	TBD: Scale, orientation, etc.
				
			}
		
		}

	
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
	
	objc_setAssociatedObject(self, &kUIImage_IRAdditions_representedObject, newObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

+ (NSMutableSet *) contextInfoToImageWritingCallbacks {

	static NSMutableSet *set;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
    set = [NSMutableSet set];
	});
	
	return set;

}

- (void) irWriteToSavedPhotosAlbumWithCompletion:(IRImageWritingCallback)aBlock {

	CFUUIDRef uuidRef = CFUUIDCreate(NULL);
	
	NSDictionary *contextInfo = [NSDictionary dictionaryWithObjectsAndKeys:
	
		[aBlock copy], kUIImage_IRAdditions_didWriteToSavedPhotosCallback,
	
	nil];
	
	[[[self class] contextInfoToImageWritingCallbacks] addObject:contextInfo];
	
	UIImageWriteToSavedPhotosAlbum(self, self, @selector(handleDidWriteImageToSavedPhotosAlbum:withError:contextInfo:), (__bridge void *)contextInfo);

}

- (void) handleDidWriteImageToSavedPhotosAlbum:(UIImage *)image withError:(NSError *)error contextInfo:(NSDictionary *)contextInfo {

	IRImageWritingCallback callback = [contextInfo objectForKey:kUIImage_IRAdditions_didWriteToSavedPhotosCallback];
	
	if (callback)
		callback(!error, error);
	
	[[[self class] contextInfoToImageWritingCallbacks] removeObject:contextInfo];

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
