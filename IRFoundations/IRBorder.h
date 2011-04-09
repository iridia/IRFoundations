//
//  IRBorder.h
//  IRFoundations
//
//  Created by Evadne Wu on 4/10/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "QuartzCore+IRAdditions.h"


@interface IRBorder : NSObject <NSCoding>

@property (nonatomic, readwrite, assign) IREdge edge;
@property (nonatomic, readwrite, assign) IRBorderType type;
@property (nonatomic, readwrite, assign) CGFloat width;
@property (nonatomic, readwrite, retain) UIColor *color;

+ (IRBorder *) borderForEdge:(IREdge)anEdge withType:(IRBorderType)aType width:(CGFloat)aWidth color:(UIColor *)aColor;

@end
