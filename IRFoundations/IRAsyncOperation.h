//
//  IRAsyncOperation.h
//  IRFoundations
//
//  Created by Evadne Wu on 10/10/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef __IRAsyncOperation__
#define __IRAsyncOperation__

typedef void(^IRAsyncOperationCallback)(id results);

#endif


@interface IRAsyncOperation : NSOperation <NSCopying>

@property (nonatomic, readonly, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, readonly, assign, getter=isFinished) BOOL finished;

@property (nonatomic, readwrite, copy) void (^workerBlock)(void(^callbackBlock)(id results));
@property (nonatomic, readwrite, copy) void (^workCompletionBlock)(id results);

@property (nonatomic, readonly, retain) id results;

+ (id) operationWithWorkerBlock:(void(^)(IRAsyncOperationCallback callback))aWorkerBlock completionBlock:(IRAsyncOperationCallback)aCompletionBlock;

@end
