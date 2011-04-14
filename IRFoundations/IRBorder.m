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

- (id) initWithCoder:(NSCoder *)aDecoder {

	self = [super init];
	if (!self) return nil;

	[(NSValue *)[aDecoder decodeObjectForKey:@"edge"] getValue:&edge];
	[(NSValue *)[aDecoder decodeObjectForKey:@"type"] getValue:&type];
	self.width = [aDecoder decodeFloatForKey:@"width"];
	self.color = [aDecoder decodeObjectForKey:@"color"];
		
	return self;

}

- (void) encodeWithCoder:(NSCoder *)aCoder {

	[aCoder encodeObject:[NSValue valueWithBytes:&edge objCType:@encode(__typeof__(edge))] forKey:@"edge"];
	[aCoder encodeObject:[NSValue valueWithBytes:&type objCType:@encode(__typeof__(type))] forKey:@"type"];
	[aCoder encodeFloat:width forKey:@"width"];
	[aCoder encodeObject:color forKey:@"color"];

}

- (void) dealloc {

	[color release];
	[super dealloc];

}


@end
