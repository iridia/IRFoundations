//
//  QuartzCore+IRAdditions.h
//  IRFoundations
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
#import "CALayer+IRAdditions.h"

extern void IRCATransact(void(^aBlock)(void));

extern CGRect IRGravitize (CGRect enclosingRect, CGSize contentSize, NSString *contentsGravity);
