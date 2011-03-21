//
//  QuartzCore+IRAdditions.h
//  Milk
//
//  Created by Evadne Wu on 2/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

// #import "IRShadow.h"
#import "IRView.h"
#import "IRStaticShapeView.h"
#import "IRGradientView.h"
#import "IRConcaveView.h"

extern void IRCATransact(void(^aBlock)(void));

@interface CALayer (IRAdditions)

+ (NSMutableDictionary *) irDefaultNoActionsDictionary;

- (void) irSetShadowColor:(UIColor *)color alpha:(CGFloat)alpha spread:(CGFloat)spread offset:(CGSize)offset;

@end
