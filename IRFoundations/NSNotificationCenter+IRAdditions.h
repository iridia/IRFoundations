//
//  NSNotificationCenter+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 4/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (IRAdditions)

- (id) irWaitForName:(NSString *)name object:(id)obj withTimeout:(NSTimeInterval)timeoutDuration callback:(void (^)(NSNotification *note))callback;

//	Observe notification with matching criteria, fire callback with incoming notification as parameter.  Also fire checking block on timeout, and if callback was not fired by then, fire callback with nil notification as parameter

@end
