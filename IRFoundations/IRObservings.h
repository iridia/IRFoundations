//
//  IRObservings.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/8/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

//  iOS only.  This is not meant to be permanant.

#import <objc/objc.h>
#import <objc/runtime.h>

#import <Foundation/Foundation.h>


typedef void (^IRObservingsCallbackBlock) (NSKeyValueChange kind, id fromValue, id toValue, NSIndexSet *indices, BOOL isPrior);

@interface NSObject (IRObservings)

- (id) irObserve:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context withBlock:(IRObservingsCallbackBlock)block;

- (void) irRemoveObservingsHelper:(id)aHelper;

- (void) irRemoveObserverBlocksForKeyPath:(NSString *)keyPath;
- (void) irRemoveObserverBlocksForKeyPath:(NSString *)keyPath context:(void *)context;

- (NSMutableArray *) irObservingsHelperBlocksForKeyPath:(NSString *)aKeyPath;

- (void) irObserveObject:(id)target keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context withBlock:(IRObservingsCallbackBlock)block;

@end


typedef void (^IRObservingsLegacyCallbackBlock) (id inOldValue, id inNewValue, NSKeyValueChange changeKind);

@interface NSObject (IRObservingsDeprecated)

- (id) irAddObserverBlock:(IRObservingsLegacyCallbackBlock)aBlock forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;

@end
