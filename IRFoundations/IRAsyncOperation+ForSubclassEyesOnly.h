//
//  IRAsyncOperation+ForSubclassEyesOnly.h
//  IRFoundations
//
//  Created by Evadne Wu on 4/6/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRAsyncOperation.h"

@interface IRAsyncOperation (SubclassEyesOnly)

@property (nonatomic, readonly, copy) IRAsyncOperationWorker worker;
@property (nonatomic, readonly, copy) IRAsyncOperationWorkerTrampoline workerTrampoline;

@property (nonatomic, readonly, copy) IRAsyncOperationCallback callback;
@property (nonatomic, readonly, copy) IRAsyncOperationCallbackTrampoline callbackTrampoline;

@property (nonatomic, readonly, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, readonly, assign, getter=isFinished) BOOL finished;

@property (nonatomic, readonly, retain) id results;

- (void) concludeWithResults:(id)incomingResults;

@end
