//
//  IRAction.h
//  Milk
//
//  Created by Evadne Wu on 2/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IRAction : NSObject

+ (IRAction *) actionWithTitle:(NSString *)title block:(void(^)(void))action;

- (void) invoke;

@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, assign) BOOL enabled;
@property (nonatomic, readwrite, copy) void (^action)();

@end
