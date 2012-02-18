//
//  NSArray+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef id (^IRMapCallback) (id inObject, NSUInteger index, BOOL *stop);


@interface NSArray (IRAdditions)

- (NSArray *) irMap:(IRMapCallback)block;
- (NSArray *) irFlatten;	// flattens contents of any array node, inserts them in place
- (NSArray *) irUnique;
- (NSArray *) irShuffle;

+ (NSArray *) irArrayByRepeatingObject:(id)anObject count:(NSUInteger)count;

- (void) irExecuteAllObjectsAsBlocks; // excepts (void)(^)(void)

- (NSArray *) irSubarraysByBreakingArrayIntoBatchesOf:(NSInteger)maxCountPerSubarray;

@end


@interface NSMutableArray (IRAdditions)

- (void) irEnqueueBlock:(void(^)(void))aBlock; // makes an autoreleased copy then enqueues
- (void) irShuffle;

+ (NSMutableArray *) irArrayByRepeatingObject:(id)anObject count:(NSUInteger)count;

@end


extern IRMapCallback irMapMakeWithKeyPath (NSString * aKeyPath);
extern IRMapCallback irMapNullFilterMake (void);
