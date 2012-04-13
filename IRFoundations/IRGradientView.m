//
//  IRGradientView.m
//  IRFoundations
//
//  Created by Evadne Wu on 1/5/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRGradientView.h"


@implementation IRGradientView

@dynamic layer;

+ (id) layerClass {

	return [CAGradientLayer class];

}

- (void) setLinearGradientFromColor:(UIColor *)fromColor anchor:(IRAnchor)fromAnchor toColor:(UIColor *)toColor anchor:(IRAnchor)toAnchor {

	self.layer.colors = [NSArray arrayWithObjects:(id)fromColor.CGColor, (id)toColor.CGColor, nil];
		
	self.layer.locations = [NSArray arrayWithObjects:
		
		[NSNumber numberWithFloat:0],
		[NSNumber numberWithFloat:1],
		
	nil];
		
	self.layer.startPoint = irUnitPointForAnchor(fromAnchor, YES);
	self.layer.endPoint = irUnitPointForAnchor(toAnchor, YES);

}

@end
