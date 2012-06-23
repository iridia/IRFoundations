//
//  UIImage+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 6/16/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//	  
//	  Portions of code in this class adapted from UIImage+Resize.m
//  Created by Trevor Harmon
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

typedef void(^IRImageWritingCallback)(BOOL didWrite, NSError *error);

@class IRShadow;
@interface UIImage (IRAdditions)

+ (UIImage *) irImageNamed:(NSString *)name inBundle:(NSBundle *)bundle;

- (UIImage *) irStandardImage;

- (UIImage *) irDecodedImage;
- (BOOL) irIsDecodedImage;

- (UIImage *) irScaledImageWithSize:(CGSize)aSize;
- (UIImage *) irSolidImageWithFillColor:(UIColor *)fillColor shadow:(IRShadow *)shadowOrNil;

@property (nonatomic, readwrite, retain, getter=irRepresentedObject, setter=irSetRepresentedObject:) id irRepresentedObject;

- (void) irWriteToSavedPhotosAlbumWithCompletion:(IRImageWritingCallback)aBlock;

+ (BOOL) validateContentsOfFileAtPath:(NSString *)path error:(NSError **)error;

@end
