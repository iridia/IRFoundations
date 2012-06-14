//
//  IROperationQueue.h
//  IRFoundations
//
//  Created by Evadne Wu on 5/31/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IROperationQueue : NSOperationQueue

- (void) beginSuspendingOperations;
- (void) endSuspendingOperations;

@end
