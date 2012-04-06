//
//  IRAsyncBarrierOperation.h
//  IRFoundations
//
//  Created by Evadne Wu on 4/6/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRAsyncOperation.h"

@interface IRAsyncBarrierOperation : IRAsyncOperation

- (void) addDependency:(IRAsyncOperation *)op;

@end
