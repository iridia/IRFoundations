//
//  IRBorder.m
//  IRFoundations
//
//  Created by Evadne Wu on 4/10/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRBorder.h"


@implementation IRBorder

@synthesize edge, type, width, color;

+ (IRBorder *) borderForEdge:(IREdge)anEdge withType:(IRBorderType)aType width:(CGFloat)aWidth color:(UIColor *)aColor {

	IRBorder *returnedBorder = [[self alloc] init];
	if (!returnedBorder)
	return nil;
	
	returnedBorder.edge = anEdge;
	returnedBorder.type = aType;
	returnedBorder.width = aWidth;
	returnedBorder.color = aColor;
	
	return [returnedBorder autorelease];

}

- (void) dealloc {

	[color release];
	[super dealloc];

}


@end
