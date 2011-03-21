//
//  IRView.m
//  Milk
//
//  Created by Evadne Wu on 1/6/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRView.h"


@implementation IRView

@synthesize onDrawRect;

- (void) drawRect:(CGRect)rect {

	if (self.onDrawRect)
	self.onDrawRect(rect, UIGraphicsGetCurrentContext());

}

- (void) dealloc {

	self.onDrawRect = nil;

	[super dealloc];

}


@end
