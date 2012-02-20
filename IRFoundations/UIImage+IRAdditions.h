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

@class IRShadow;
@interface UIImage (IRAdditions)

- (UIImage *) irStandardImage;
- (UIImage *) irDecodedImage;

- (UIImage *) irScaledImageWithSize:(CGSize)aSize;
- (UIImage *) irSolidImageWithFillColor:(UIColor *)fillColor shadow:(IRShadow *)shadowOrNil;

@property (nonatomic, readwrite, retain, getter=irRepresentedObject, setter=irSetRepresentedObject:) id irRepresentedObject;

- (void) irWriteToSavedPhotosAlbumWithCompletion:(void(^)(BOOL didWrite, NSError *error))aBlock;

+ (BOOL) validateContentsOfFileAtPath:(NSString *)path error:(NSError **)error;

@end
