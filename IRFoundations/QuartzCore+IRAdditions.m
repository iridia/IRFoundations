//
//  QuartzCore+IRAdditions.m
//  Milk
//
//  Created by Evadne Wu on 2/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "QuartzCore+IRAdditions.h"


void IRCATransact(void(^aBlock)(void)) {

	[CATransaction begin];
	[CATransaction setAnimationDuration:0.0];
	[CATransaction setDisableActions:YES];
	
	if (aBlock)
	aBlock();

	[CATransaction commit];

}
