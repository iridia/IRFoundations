//
//  IRAsyncOperation.h
//  IRFoundations
//
//  Created by Evadne Wu on 10/10/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRAsyncOperation : NSOperation

@property (nonatomic, readonly, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, readonly, assign, getter=isFinished) BOOL finished;

@property (nonatomic, readwrite, copy) void (^workerBlock)(void(^callbackBlock)(id results));
@property (nonatomic, readwrite, copy) void (^workCompletionBlock)(id results);

@end
