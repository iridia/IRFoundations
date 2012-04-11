//
//  IRGradientView.h
//  IRFoundations
//
//  Created by Evadne Wu on 1/5/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CGGeometry+IRAdditions.h"

@interface IRGradientView : UIView

@property (nonatomic, readonly, retain) CAGradientLayer *layer;

- (void) setLinearGradientFromColor:(UIColor *)fromColor anchor:(IRAnchor)fromAnchor toColor:(UIColor *)toColor anchor:(IRAnchor)toAnchor;

@end
