//
//  IROperationQueue.m
//  IRFoundations
//
//  Created by Evadne Wu on 5/31/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IROperationQueue.h"

static NSString * const kDispatchQueue = @"+[IROperationQueue dispatchQueue]";

@interface IROperationQueue ()

@property (nonatomic, readwrite, assign) NSUInteger suspendingCount;

+ (dispatch_queue_t) dispatchQueue;

@end


@implementation IROperationQueue
@synthesize suspendingCount = _suspendingCount;

- (void) setSuspended:(BOOL)flag {

	[NSException raise:NSInternalInconsistencyException format:@"%s is handled internally by %@ and should not be used by external code.", __PRETTY_FUNCTION__, NSStringFromClass([self class])];
	
	[super setSuspended:flag];

}

- (void) beginSuspendingOperations {

	dispatch_sync([[self class] dispatchQueue], ^{
		
		_suspendingCount += 1;
		
		if (_suspendingCount == 1)
			[super setSuspended:YES];
		
	});

}

- (void) endSuspendingOperations {

	dispatch_sync([[self class] dispatchQueue], ^{
		
		NSCParameterAssert(_suspendingCount);
		_suspendingCount -= 1;
		
		if (_suspendingCount == 0)
			[super setSuspended:NO];
		
	});

}

+ (dispatch_queue_t) dispatchQueue {

	static dispatch_once_t onceToken;
	static dispatch_queue_t dispatchQueue;
	dispatch_once(&onceToken, ^{
		dispatchQueue = dispatch_queue_create([NSStringFromClass([self class]) UTF8String], DISPATCH_QUEUE_SERIAL);
	});
	
	return dispatchQueue;

}

@end
