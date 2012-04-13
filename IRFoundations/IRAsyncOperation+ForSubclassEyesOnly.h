//
//  IRAsyncOperation+ForSubclassEyesOnly.h
//  IRFoundations
//
//  Created by Evadne Wu on 4/6/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRAsyncOperation.h"

@interface IRAsyncOperation ()

@property (nonatomic, readwrite, assign) dispatch_queue_t actualDispatchQueue;
@property (nonatomic, readwrite, retain) id results;

- (void) onMainQueue:(void(^)(void))aBlock;
- (void) concludeWithResults:(id)incomingResults;

@end
