//
//  NSThread+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSThread+IRAdditions.h"

@implementation NSThread (IRAdditions)

+ (void) irLogCallStackSymbols {

	NSLog(@"%@", [self callStackSymbols]);

}

@end


void IRLogExceptionAndContinue (void(^operation)(void)) {

	@try {
	
		operation();
	
	} @catch (NSException *exception) {
	
		NSLog(@"Exception: %@", exception);
		@throw exception;
	
	}

}
