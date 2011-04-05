//
//  Foundation+IRAdditions.h
//  Milk
//
//  Created by Evadne Wu on 1/14/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IRNoOp.h"
#import "IRBindings.h"
#import "IRObservings.h"
#import "IRXPathQuery.h"

#import "IRHTMLStringFormatter.h"

#import "CGGeometry+IRAdditions.h"

#ifndef __Foundation_IRAdditions__
#define __Foundation_IRAdditions__

typedef id (^IRMapCallback) (id inObject, int index, BOOL *stop);

extern IRMapCallback irMapMakeWithKeyPath (NSString * aKeyPath);
extern IRMapCallback irMapNullFilterMake ();
extern IRMapCallback irMapFrameValuesFromViews ();
extern IRMapCallback irMapBoundsValuesFromViews ();
extern IRMapCallback irMapOriginValuesFromRectValues ();
extern IRMapCallback irMapCenterPointValuesFromRectValues ();

extern NSComparator irComparatorMakeWithNodeKeyPath (NSString *aKeyPath);
extern NSUInteger irCount (id anObject, NSUInteger placeholderValue);

extern void IRLogExceptionAndContinue (void(^)(void));

#endif


@interface NSObject (IRAdditions)

- (void) irExecute; // typecasts object to (void)(^)(void)

@end





@interface NSArray (IRAdditions)

- (NSArray *) irMap:(id(^)(id inObject, int index, BOOL *stop))block;
- (NSArray *) irFlatten;	// flattens contents of any array node, inserts them in place
- (NSArray *) irUnique;

+ (NSArray *) irArrayByRepeatingObject:(id)anObject count:(NSUInteger)count;

- (void) irExecuteAllObjectsAsBlocks; // excepts (void)(^)(void)

- (NSArray *) irSubarraysByBreakingArrayIntoBatchesOf:(NSInteger)maxCountPerSubarray;

@end

@interface NSMutableArray (IRAdditions)

- (void) irEnqueueBlock:(void(^)(void))aBlock; // makes an autoreleased copy then enqueues

@end






@interface NSSet (IRAdditions)

- (NSSet *) irSetByRemovingObjectsInSet:(NSSet *)subtractedSet;

@end





@interface NSThread (IRAdditions)

+ (void) irLogCallStackSymbols;

@end




