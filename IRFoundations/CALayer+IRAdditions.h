//
//  CALayer+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 9/6/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer (IRAdditions)

+ (NSMutableDictionary *) irDefaultNoActionsDictionary;
- (void) irSetShadowColor:(UIColor *)color alpha:(CGFloat)alpha spread:(CGFloat)spread offset:(CGSize)offset;

@end
