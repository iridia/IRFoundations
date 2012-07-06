//
//  IRAsyncOperation.m
//  IRFoundations
//
//  Created by Evadne Wu on 10/10/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "IRAsyncOperation.h"
#import "IRAsyncOperation+ForSubclassEyesOnly.h"


@interface IRAsyncOperation ()

@property (nonatomic, readwrite, copy) IRAsyncOperationWorker worker;
@property (nonatomic, readwrite, copy) IRAsyncOperationTrampoline workerTrampoline;

@property (nonatomic, readwrite, copy) IRAsyncOperationCallback callback;
@property (nonatomic, readwrite, copy) IRAsyncOperationTrampoline callbackTrampoline;

@property (nonatomic, readonly, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, readonly, assign, getter=isFinished) BOOL finished;

@property (nonatomic, readwrite, retain) id results;

@end


@implementation IRAsyncOperation

@synthesize executing, finished;
@synthesize worker, workerTrampoline, callback, callbackTrampoline;
@synthesize results;

+ (id) operationWithWorker:(IRAsyncOperationWorker)inWorker trampoline:(IRAsyncOperationTrampoline)inWorkerTrampoline callback:(IRAsyncOperationCallback)inCallback callbackTrampoline:(IRAsyncOperationTrampoline)inCallbackTrampoline {

	IRAsyncOperation *op = [[self alloc] init];
	
	op.worker = inWorker;
	op.workerTrampoline = inWorkerTrampoline ? inWorkerTrampoline : [op copyDefaultWorkerTrampoline];
	
	op.callback = inCallback;
	op.callbackTrampoline = inCallbackTrampoline ? inCallbackTrampoline : [op copyDefaultCallbackTrampoline];
	
	return op;

}

+ (id) operationWithWorker:(IRAsyncOperationWorker)inWorker callback:(IRAsyncOperationCallback)inCallback {

	return [self operationWithWorker:inWorker trampoline:nil callback:inCallback callbackTrampoline:nil];

}

+ (id) operationWithWorkerBlock:(void (^)(IRAsyncOperationCallback callback))inWorker completionBlock:(IRAsyncOperationCallback)inCallback {

	return [self operationWithWorker:inWorker trampoline:nil callback:inCallback callbackTrampoline:nil];

}

- (id) copyWithZone:(NSZone *)zone {

	IRAsyncOperation *op = [[[self class] alloc] init];
	
	op.worker = worker;
	op.workerTrampoline = workerTrampoline;
	
	op.callback = callback;
	op.callbackTrampoline = callbackTrampoline;
	
	op.results = results;
	
	return op;

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

- (void) concludeWithResults:(id)incomingResults {

	if ([self isCancelled])
		return;
	
	self.callbackTrampoline(^ {
		
		self.results = incomingResults;
		
		if (self.callback)
			self.callback(self.results);
		
		self.executing = NO;
		self.finished = YES;
		
	});
	
}

- (void) start {

	if ([self isCancelled]) {
		self.finished = YES;
		return;
	}
	
	self.executing = YES;
	
	[self main];

}

- (void) main {

	self.workerTrampoline(^ {
		
		if (self.worker) {
			
			self.worker([ ^ (id incomingResults) {
				[self concludeWithResults:incomingResults];
			} copy]);
		
		}
		
	});

}

- (void) cancel {

	[super cancel];

	if (self.executing)
		self.finished = YES;
	
	self.executing = NO;
	
	if (self.callback)
		self.callback(nil);
	
}

- (IRAsyncOperationTrampoline) copyDefaultWorkerTrampoline {

	return [^(void(^workerInvoker)(void)) {
	
		dispatch_async(dispatch_get_main_queue(), workerInvoker);
	
	} copy];

}

- (IRAsyncOperationTrampoline) copyDefaultCallbackTrampoline {

	return [^(void(^callbackInvoker)(void)) {
	
		dispatch_async(dispatch_get_main_queue(), callbackInvoker);
	
	} copy];

}

@end
