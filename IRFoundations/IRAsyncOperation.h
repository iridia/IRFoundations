//
//  IRAsyncOperation.h
//  IRFoundations
//
//  Created by Evadne Wu on 10/10/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>


@class IRAsyncOperation;

typedef void (^IRAsyncOperationCallback)(id results);
typedef void (^IRAsyncOperationWorker)(IRAsyncOperationCallback callback);

typedef void (^IRAsyncOperationCallbackTrampoline)(void(^block)(void));
typedef void (^IRAsyncOperationWorkerTrampoline)(void(^block)(void));


@interface IRAsyncOperation : NSOperation <NSCopying>

+ (id) operationWithWorker:(IRAsyncOperationWorker)worker callback:(IRAsyncOperationCallback)callback;

+ (id) operationWithWorker:(IRAsyncOperationWorker)worker trampoline:(IRAsyncOperationWorkerTrampoline)workerTrampoline callback:(IRAsyncOperationCallback)callback callbackTrampoline:(IRAsyncOperationCallbackTrampoline)callbackTrampoline;

- (IRAsyncOperationWorkerTrampoline) copyDefaultWorkerTrampoline;
- (IRAsyncOperationCallbackTrampoline) copyDefaultCallbackTrampoline;

@end


@interface IRAsyncOperation (Deprecated)

+ (id) operationWithWorkerBlock:(void(^)(IRAsyncOperationCallback callback))aWorkerBlock completionBlock:(IRAsyncOperationCallback)aCompletionBlock;

@end