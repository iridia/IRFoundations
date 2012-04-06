//
//  NSSet+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSSet+IRAdditions.h"

@implementation NSSet (IRAdditions)

- (NSSet *) irMap:(IRSetMapCallback)mapBlock {

	NSMutableSet *returnedSet = [NSMutableSet setWithCapacity:[self count]];

	NSUInteger index = 0;
	BOOL stop = NO;

	for (id object in self) {
	
		id returnedObject = mapBlock(object, &stop);
		
		if (returnedObject)
			[returnedSet addObject:returnedObject];
		
		index++;
		
		if (stop)
		break;
			
	}
	
	return returnedSet;

}

- (NSSet *) irSetByRemovingObjectsInSet:(NSSet *)subtractedSet {

	NSMutableSet *returnedSet = [[self mutableCopy] autorelease];
	[returnedSet minusSet:subtractedSet];
	
	return [[returnedSet copy] autorelease];

}

@end
