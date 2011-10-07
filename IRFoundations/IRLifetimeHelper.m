//
//  IRLifetimeHelper.m
//  IRFoundations
//
//  Created by Evadne Wu on 10/7/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <objc/runtime.h>
#import "IRLifetimeHelper.h"


static NSString *kIRLifetimeHelpers = @"IRLifetimeHelpers";

@implementation NSObject (IRLifetimeHelperAdditions)

- (void) irPerformOnDeallocation:(void(^)(void))aBlock {

	[[self irLifetimeHelpers] addObject:[IRLifetimeHelper helperWithDeallocationCallback:aBlock]];

}

- (NSMutableSet *) irLifetimeHelpers {

	NSMutableSet *returnedSet = objc_getAssociatedObject(self, &kIRLifetimeHelpers);
	if (returnedSet)
		return returnedSet;
	
	returnedSet = [NSMutableSet set];
	objc_setAssociatedObject(self, &kIRLifetimeHelpers, returnedSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	return returnedSet;

}

@end


@implementation IRLifetimeHelper
@synthesize deallocationCallback;

+ (id) helperWithDeallocationCallback:(void(^)(void))aBlock {

	IRLifetimeHelper *returnedHelper = [[[self alloc] init] autorelease];
	returnedHelper.deallocationCallback = aBlock;
	
	return returnedHelper;

}

- (void) dealloc {

	if (deallocationCallback)
		deallocationCallback();
	
	[deallocationCallback release];
	[super dealloc];

}

@end
