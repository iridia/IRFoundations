//
//  IRAsyncBarrierOperation.m
//  IRFoundations
//
//  Created by Evadne Wu on 4/6/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRAsyncBarrierOperation.h"
#import "IRAsyncOperation+ForSubclassEyesOnly.h"


@interface IRAsyncBarrierOperation ()

- (BOOL) hasFailedDependency;

@end


@implementation IRAsyncBarrierOperation

- (void) addDependency:(IRAsyncOperation *)op {

	NSParameterAssert([op isKindOfClass:[IRAsyncOperation class]]);
	[super addDependency:op];

}

- (BOOL) hasFailedDependency {

	for (IRAsyncOperation *op in self.dependencies)
	if ([op isCancelled] || ([op isFinished] && (!op.results || [op.results isKindOfClass:[NSError class]])))
		return YES;
	
	return NO;

}

- (void) main {

	if ([self hasFailedDependency]) {
	
		[self onMainQueue: ^ {
		
			[self concludeWithResults:[NSError errorWithDomain:@"com.iridia.asyncOperation" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
			
				@"Operation is not going to run its worker block because a dependent operation has failed", NSLocalizedDescriptionKey,
			
			nil]]];
			
		}];
		
		return;
	
	}

	[super main];
	
}

@end
