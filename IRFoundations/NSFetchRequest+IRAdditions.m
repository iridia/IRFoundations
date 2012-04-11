//
//  NSFetchRequest+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/10/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "NSFetchRequest+IRAdditions.h"





NSString * const kIRPrefetchedEntityRelationshipKeyPaths = @"kIRPrefetchedEntityRelationshipKeyPaths";

@implementation NSFetchRequest (IRAdditions)

- (NSArray *) irRelationshipKeyPathsForObjectsPrefetching {

	return objc_getAssociatedObject(self, kIRPrefetchedEntityRelationshipKeyPaths);
	
}

- (void) setIrRelationshipKeyPathsForObjectsPrefetching:(NSArray *)value {

	objc_setAssociatedObject(self, kIRPrefetchedEntityRelationshipKeyPaths, value, OBJC_ASSOCIATION_RETAIN);

}

@end
