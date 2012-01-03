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
#import "IRRelativeDateFormatter.h"

#import "CGGeometry+IRAdditions.h"

#ifndef __Foundation_IRAdditions__
#define __Foundation_IRAdditions__

typedef id (^IRMapCallback) (id inObject, NSUInteger index, BOOL *stop);

extern IRMapCallback irMapMakeWithKeyPath (NSString * aKeyPath);
extern IRMapCallback irMapNullFilterMake (void);
extern IRMapCallback irMapFrameValuesFromViews (void);
extern IRMapCallback irMapBoundsValuesFromViews (void);
extern IRMapCallback irMapOriginValuesFromRectValues (void);
extern IRMapCallback irMapCenterPointValuesFromRectValues (void);

extern NSComparator irComparatorMakeWithNodeKeyPath (NSString *aKeyPath);
extern NSUInteger irCount (id anObject, NSUInteger placeholderValue);

extern void IRLogExceptionAndContinue (void(^)(void));

typedef BOOL (^IRDictionaryPairTest) (id key, id value);

#endif


@interface NSObject (IRAdditions)

- (void) irExecute; // typecasts object to (void)(^)(void)
- (BOOL) irIsBlock;

@end


@interface NSString (IRAdditions)

- (NSString *) irTailTruncatedStringWithMaxLength:(NSUInteger)maxCharacters;

@end


@interface NSArray (IRAdditions)

- (NSArray *) irMap:(id(^)(id inObject, NSUInteger index, BOOL *stop))block;
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


@interface NSDictionary (IRAdditions)

- (BOOL) irPassesTestSuite:(NSDictionary *)aSuite;
//	The suite is a dictionary of keys to IRDictionaryPairTest blocks

- (NSDictionary *) irDictionaryBySettingObject:(id)anObject forKey:(NSString *)aKey;

- (NSDictionary *) irDictionaryByMergingWithDictionary:(NSDictionary *)aDictionary;
//	Currently a shallow merge

@end


@interface NSSet (IRAdditions)

- (NSSet *) irSetByRemovingObjectsInSet:(NSSet *)subtractedSet;

@end





@interface NSThread (IRAdditions)

+ (void) irLogCallStackSymbols;

@end




