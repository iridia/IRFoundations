//
//  IRAsyncOperation.h
//  IRFoundations
//
//  Created by Evadne Wu on 10/10/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRAsyncOperation : NSOperation <NSCopying>

@property (nonatomic, readonly, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, readonly, assign, getter=isFinished) BOOL finished;

@property (nonatomic, readwrite, copy) void (^workerBlock)(void(^callbackBlock)(id results));
@property (nonatomic, readwrite, copy) void (^workCompletionBlock)(id results);

+ (IRAsyncOperation *) operationWithWorkerBlock:(void(^)(void(^)(id results)))aWorkerBlock completionBlock:(void(^)(id results))aCompletionBlock;

@end
