//
//  IRAsyncOperationTest.m
//  IRFoundations
//
//  Created by Evadne Wu on 4/6/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRAsyncOperation.h"
#import "IRAsyncOperationTest.h"

#import <objc/runtime.h>

@implementation IRAsyncOperationTest

- (void) testOperationQueueing {

	//	This will mostly die because the Async Operation currently works on the main thread, and to 

	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	[queue setMaxConcurrentOperationCount:1];
	
	NSMutableArray *operations = [NSMutableArray array];
	
	IRAsyncOperation * (^operation)(void) = ^ {
	
		NSString * const kGeneratedResultTag = @"generatedResult";
	
		__block IRAsyncOperation *operation = [[IRAsyncOperation operationWithWorkerBlock:^(IRAsyncOperationCallback callback) {
		
			STAssertTrue([NSThread isMainThread], @"Operation %@ must be running its worker block on the main thread", self);
			NSUInteger ownIndex = [operations indexOfObject:operation];
			STAssertFalse(ownIndex == NSNotFound, @"Operation %@ must be tracked by the test case");
			
			[operations enumerateObjectsUsingBlock:^(NSOperation *otherOp, NSUInteger idx, BOOL *stop) {
				
				if (idx < ownIndex) {

					STAssertFalse([otherOp isExecuting], @"Previous operation %@ must not be executing", otherOp);
					STAssertTrue([otherOp isFinished], @"Previous operation %@ must have finished", otherOp);
					STAssertFalse([otherOp isCancelled], @"Previous operation %@ must have not been cancelled", otherOp);
				
				} else if (idx == ownIndex) {
				
					//	No op
				
				} else {
				
					STAssertFalse([otherOp isExecuting], @"Further operation %@ must not be executing", otherOp);
					STAssertFalse([otherOp isFinished], @"Further operation %@ must have not finished", otherOp);
					STAssertFalse([otherOp isCancelled], @"Further operation %@ must have not been cancelled", otherOp);
				
				}
				
			}];
			
			NSLog(@"Running as operation %lu", (long)ownIndex);
			
			NSString *result = [NSMakeCollectable(CFUUIDCreateString(NULL, (CFUUIDRef)[NSMakeCollectable(CFUUIDCreate(NULL)) autorelease])) autorelease];
			
			objc_setAssociatedObject(operation, kGeneratedResultTag, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

			callback(result);
			
		} completionBlock: ^ (id results) {
		
			STAssertEqualObjects(results, objc_getAssociatedObject(operation, kGeneratedResultTag), @"Result must be passed correctly, as exactly the same object");
			
			STAssertTrue([NSThread isMainThread], @"Operation %@ must be running its completion block on the main thread", self);
			NSUInteger ownIndex = [operations indexOfObject:operation];
			STAssertFalse(ownIndex == NSNotFound, @"Operation %@ must be tracked by the test case");
			
			[operations enumerateObjectsUsingBlock:^(NSOperation *otherOp, NSUInteger idx, BOOL *stop) {
				
				if (idx < ownIndex) {

					STAssertFalse([otherOp isExecuting], @"Previous operation %@ must not be executing", otherOp);
					STAssertTrue([otherOp isFinished], @"Previous operation %@ must have finished", otherOp);
					STAssertFalse([otherOp isCancelled], @"Previous operation %@ must have not been cancelled", otherOp);
				
				} else if (idx == ownIndex) {
				
					//	No op
				
				} else {
				
					STAssertFalse([otherOp isExecuting], @"Further operation %@ must not be executing", otherOp);
					STAssertFalse([otherOp isFinished], @"Further operation %@ must have not finished", otherOp);
					STAssertFalse([otherOp isCancelled], @"Further operation %@ must have not been cancelled", otherOp);
				
				}
				
			}];
			
			[operation autorelease];
			
		}] retain];
		
		return operation;

	};
	
	for (int i = 0; i < 100; i++)
		[operations addObject:operation()];
	
	[queue addOperations:operations waitUntilFinished:NO];

	while (queue.operationCount)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]];

}

@end
