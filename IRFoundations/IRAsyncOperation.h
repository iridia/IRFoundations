//
//  IRAsyncOperation.h
//  IRFoundations
//
//  Created by Evadne Wu on 10/10/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>


@class IRAsyncOperation;

typedef void (^IRAsyncOperationInvoker)(void);

typedef void (^IRAsyncOperationCallback)(id results);
typedef void (^IRAsyncOperationWorker)(IRAsyncOperationCallback callback);
typedef void (^IRAsyncOperationTrampoline)(IRAsyncOperationInvoker callback);


@interface IRAsyncOperation : NSOperation <NSCopying>

+ (id) operationWithWorker:(IRAsyncOperationWorker)worker callback:(IRAsyncOperationCallback)callback;

+ (id) operationWithWorker:(IRAsyncOperationWorker)worker trampoline:(IRAsyncOperationTrampoline)workerTrampoline callback:(IRAsyncOperationCallback)callback callbackTrampoline:(IRAsyncOperationTrampoline)callbackTrampoline;

- (IRAsyncOperationTrampoline) copyDefaultWorkerTrampoline;
- (IRAsyncOperationTrampoline) copyDefaultCallbackTrampoline;

@end

@interface IRAsyncOperation (Deprecated)

+ (id) operationWithWorkerBlock:(void(^)(IRAsyncOperationCallback callback))aWorkerBlock completionBlock:(IRAsyncOperationCallback)aCompletionBlock;

@end
