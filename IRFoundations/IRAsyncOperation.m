//
//  IRAsyncOperation.m
//  IRFoundations
//
//  Created by Evadne Wu on 10/10/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "IRAsyncOperation.h"

@interface IRAsyncOperation ()

@property (nonatomic, readwrite, assign) dispatch_queue_t actualDispatchQueue;
@property (nonatomic, readwrite, retain) id results;

- (void) onMainQueue:(void(^)(void))aBlock;
- (void) concludeWithResults:(id)incomingResults;

@end


@implementation IRAsyncOperation

@synthesize executing, finished;
@synthesize workerBlock, workCompletionBlock;
@synthesize actualDispatchQueue, results;

- (void) dealloc {

	[workerBlock release];
	[workCompletionBlock release];
	[results release];
	
	[super dealloc];

}

- (BOOL) isConcurrent {

	return YES;

}

- (void) setFinished:(BOOL)newFinished {

	if (newFinished == finished)
		return;
	
	[self willChangeValueForKey:@"isFinished"];
	[self willChangeValueForKey:@"progress"];
	
	finished = newFinished;
	
	[self didChangeValueForKey:@"progress"];
	[self didChangeValueForKey:@"isFinished"];

}

- (void) setExecuting:(BOOL)newExecuting {

	if (newExecuting == executing)
		return;
	
	[self willChangeValueForKey:@"isExecuting"];
	executing = newExecuting;
	[self didChangeValueForKey:@"isExecuting"];

}

- (void) onMainQueue:(void(^)(void))aBlock {
	
	self.actualDispatchQueue = dispatch_get_current_queue();
	dispatch_async(dispatch_get_main_queue(), aBlock);
	
}

- (void) concludeWithResults:(id)incomingResults {

	if ([self isCancelled])
		return;

	dispatch_async(self.actualDispatchQueue, ^ {
		
		self.executing = NO;
		self.finished = YES;
		
		if (self.workCompletionBlock)
			self.workCompletionBlock(incomingResults);
		
	});
	
}

- (void) start {

	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
		return;
	}

	if ([self isCancelled]) {
		self.finished = YES;
		return;
	}
	
	self.executing = YES;
	[self main];

}

- (void) cancel {

	dispatch_async(self.actualDispatchQueue, ^ {
		
		self.executing = NO;
		self.finished = YES;
		
		if (self.workCompletionBlock)
			self.workCompletionBlock(nil);
		
	});

}

- (void) main {

	[self onMainQueue: ^ {
	
		if (!self.workerBlock)
			return;
			
		self.workerBlock([[ ^ (id incomingResults) {
			[self concludeWithResults:incomingResults];
		} copy] autorelease]);
		
	}];

}

@end
