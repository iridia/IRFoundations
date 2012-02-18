//
//  NSSet+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSSet+IRAdditions.h"

@implementation NSSet (IRAdditions)

- (NSSet *) irSetByRemovingObjectsInSet:(NSSet *)subtractedSet {

	NSMutableSet *returnedSet = [[self mutableCopy] autorelease];
	[returnedSet minusSet:subtractedSet];
	
	return [[returnedSet copy] autorelease];

}

@end
