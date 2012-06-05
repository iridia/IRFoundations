//
//  UIViewController+IRDelayedUpdateAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 5/31/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+IRDelayedUpdateAdditions.h"
#import "IROperationQueue.h"
#import "IRAsyncOperation.h"

static NSString * const kQueue = @"-[UIViewController(IRDelayedUpdateAdditions) queue]";

@implementation UIViewController (IRDelayedUpdateAdditions)

- (IROperationQueue *) queue {

	IROperationQueue *queue = objc_getAssociatedObject(self, &kQueue);
	if (!queue) {
		queue = [[IROperationQueue alloc] init];
		queue.maxConcurrentOperationCount = 1;
		objc_setAssociatedObject(self, &kQueue, queue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return queue;

}

- (void) enqueueUpdate:(void(^)(void))block {

	NSOperation *op = [IRAsyncOperation operationWithWorker:^(IRAsyncOperationCallback callback) {
	
		block();
		callback((id)kCFBooleanTrue);
		
	} trampoline:^(IRAsyncOperationInvoker block) {
		
		dispatch_async(dispatch_get_main_queue(), block);
		
	} callback:nil callbackTrampoline:^(IRAsyncOperationInvoker block) {
		
		dispatch_async(dispatch_get_main_queue(), block);
		
	}];

	[self.queue addOperation:[NSArray arrayWithObject:op]];

}

- (void) cancelUpdates {

	[self.queue cancelAllOperations];

}

@end
