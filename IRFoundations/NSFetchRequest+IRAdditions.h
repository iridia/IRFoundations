//
//  NSFetchRequest+IRAdditions.h
//  Milk
//
//  Created by Evadne Wu on 2/10/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <CoreData/CoreData.h>

#import <objc/objc.h>
#import <objc/runtime.h>





extern NSString * const kIRPrefetchedEntityRelationshipKeyPaths;

@interface NSFetchRequest (IRAdditions)

@property (nonatomic, readwrite, retain) NSArray *irRelationshipKeyPathsForObjectsPrefetching;

//	Any key path included in this array triggers a new fetch request and prefetcnes them
//	For example, including @"owner" will cause the objects, that the @"owner" relationships point to, to also be awaken from fault.

@end
