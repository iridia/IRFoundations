//
//  IRActionSheetTest.m
//  IRFoundations
//
//  Created by Evadne Wu on 4/13/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRActionSheetTest.h"
#import "UIKit+IRAdditions.h"

@implementation IRActionSheetTest

- (void) testActionSheet {

	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	[queue setMaxConcurrentOperationCount:1];
	
	__block IRActionSheetController *actionSheetController;
	
	[queue addOperation:[IRAsyncOperation operationWithWorkerBlock:^(IRAsyncOperationCallback callback) {
	
		actionSheetController = [IRActionSheetController actionSheetControllerWithTitle:nil cancelAction:[IRAction actionWithTitle:@"Cancel" block:^{
			
			callback(nil);
			
		}] destructiveAction:nil otherActions:nil];
		
		[actionSheetController.managedActionSheet showInView:[UIApplication sharedApplication].keyWindow];
		
	} completionBlock:^(id results) {
		
//		STAssertTrue([alertView isVisible], @"Alert view must be visible after being told to show");
		actionSheetController = nil;
		
	}]];
	
	while (queue.operationCount)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	
	STAssertNil(actionSheetController, @"Action Sheet Controller must have been deallocated");
	
	actionSheetController = nil;

}

@end
