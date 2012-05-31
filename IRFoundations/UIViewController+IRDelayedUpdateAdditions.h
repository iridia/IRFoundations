//
//  UIViewController+IRDelayedUpdateAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 5/31/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IROperationQueue;
@interface UIViewController (IRDelayedUpdateAdditions)

@property (nonatomic, readonly, strong) IROperationQueue *queue;

- (void) enqueueUpdate:(void(^)(void))block;
- (void) cancelUpdates;

@end
