//
//  IRFoundationsTouchTest.m
//  IRFoundationsTouchTest
//
//  Created by Evadne Wu on 4/13/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRAlertViewTest.h"
#import "Foundation+IRAdditions.h"
#import "UIKit+IRAdditions.h"

@implementation IRAlertViewTest

- (void) testAlertViewTrampolining {

	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:1];
	
	__block IRAlertView *alertView;
	
	[queue addOperation:[IRAsyncOperation operationWithWorkerBlock:^(IRAsyncOperationCallback callback) {
	
		alertView = [IRAlertView alertViewWithTitle:@"Test Title" message:@"Test Message" cancelAction:[IRAction actionWithTitle:@"Cancel" block:^{
			
			callback(nil);
			
		}] otherActions:nil];
		
		[alertView show];
		
	} completionBlock:^(id results) {
		
		STAssertTrue([alertView isVisible], @"Alert view must be visible after being told to show");
		alertView = nil;
		
	}]];
	
	while (queue.operationCount)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	
	STAssertNil(alertView, @"Alert view must have been deallocated");

}

@end
