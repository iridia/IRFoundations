//
//  IRShapeView.m
//  IRFoundations
//
//  Created by Evadne Wu on 1/6/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRShapeView.h"


@implementation IRShapeView

@dynamic layer;

+ (Class) layerClass {

	return [CAShapeLayer class];

}

@end
