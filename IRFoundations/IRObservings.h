//
//  IRObservings.h
//  Milk
//
//  Created by Evadne Wu on 2/8/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

//  iOS only.  This is not meant to be permanant.

#import <objc/objc.h>
#import <objc/runtime.h>

#import <Foundation/Foundation.h>


typedef void (^IRObservingsCallbackBlock) (id inOldValue, id inNewValue, NSString *changeKind);

@interface NSObject (IRObservings)

- (void) irAddObserverBlock:(void(^)(id inOldValue, id inNewValue, NSString *changeKind))aBlock forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;

- (void) irRemoveObserverBlocksForKeyPath:(NSString *)aKeyPath;

@end
