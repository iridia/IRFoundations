//
//  IRNoOp.m
//  Milk
//
//  Created by Evadne Wu on 1/14/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRNoOp.h"


static IRNoOp *IRNoOpSharedNoOp = nil;

@implementation IRNoOp

+ (IRNoOp *) noOp {

	if (!IRNoOpSharedNoOp)
	IRNoOpSharedNoOp = [[IRNoOp alloc] init];
	
	return IRNoOpSharedNoOp;

}

- (BOOL) isEqual:(id)object {

	return [object isKindOfClass:[self class]];

}

- (id) initWithCoder:(NSCoder *)aCoder {

	return [[self class] noOp];

}

- (void) encodeWithCoder:(NSCoder *)aCoder {

//	Do nothing

}

- (id) copyWithZone:(NSZone *)zone {

	return [[self class] noOp];

}

@end
