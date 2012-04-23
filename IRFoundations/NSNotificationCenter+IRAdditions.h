//
//  NSNotificationCenter+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 4/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (IRAdditions)

- (id) irWaitForName:(NSString *)name object:(id)obj withTimeout:(NSTimeInterval)timeoutDuration callback:(void (^)(BOOL didCatch, NSNotification *note))callback;

//	Observe notification with matching criteria, fire callback on main queue, or remove observation and fire callback on main queue after hitting timeout

@end
