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


typedef void (^IRObservingsCallbackBlock) (id inOldValue, id inNewValue, NSKeyValueChange changeKind);

@interface NSObject (IRObservings)

- (id) irAddObserverBlock:(IRObservingsCallbackBlock)aBlock forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;

- (void) irRemoveObservingsHelper:(id)aHelper;

- (void) irRemoveObserverBlocksForKeyPath:(NSString *)keyPath;
- (void) irRemoveObserverBlocksForKeyPath:(NSString *)keyPath context:(void *)context;

- (NSMutableArray *) irObservingsHelperBlocksForKeyPath:(NSString *)aKeyPath;

@end
