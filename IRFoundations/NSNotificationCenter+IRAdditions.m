//
//  NSNotificationCenter+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 4/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSNotificationCenter+IRAdditions.h"

@implementation NSNotificationCenter (IRAdditions)

- (id) irWaitForName:(NSString *)name object:(id)obj withTimeout:(NSTimeInterval)timeoutDuration callback:(void (^)(NSNotification *note))callback {

	CFAbsoluteTime nonce = CFAbsoluteTimeGetCurrent();
	
	__weak NSNotificationCenter *wSelf = self;
	__block id object = [self addObserverForName:name object:obj queue:nil usingBlock:^(NSNotification *note) {
		
		if (callback)
			callback(note);
		
		[wSelf removeObserver:object];
		object = nil;
		
	}];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeoutDuration * NSEC_PER_SEC), dispatch_get_main_queue(), ^ {
			
		if (object)
			if (callback)
				callback(nil);
		
		object = nil;
			
	});
	
	return object;

}

@end
