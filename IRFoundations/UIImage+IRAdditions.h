//
//  UIImage+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 6/16/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@class IRShadow;
@interface UIImage (IRAdditions)

- (UIImage *) irStandardImage;
- (UIImage *) irDecodedImage;

- (UIImage *) irScaledImageWithSize:(CGSize)aSize;
- (UIImage *) irSolidImageWithFillColor:(UIColor *)fillColor shadow:(IRShadow *)shadowOrNil;

@end
