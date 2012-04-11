//
//  IRNoOp.m
//  IRFoundations
//
//  Created by Evadne Wu on 1/14/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRNoOp.h"


@implementation IRNoOp

+ (IRNoOp *) noOp {

	static IRNoOp *instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^ {
			instance = [[self alloc] init];
	});

	return instance;

}

- (BOOL) isEqual:(id)object {

	return [object isKindOfClass:[self class]];

}

- (id) initWithCoder:(NSCoder *)aCoder {

	return [self init];

}

- (void) encodeWithCoder:(NSCoder *)aCoder {

//	Do nothing

}

- (id) copyWithZone:(NSZone *)zone {

	return [[[self class] alloc] init];

}

@end
