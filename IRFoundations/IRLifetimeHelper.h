//
//  IRLifetimeHelper.h
//  IRFoundations
//
//  Created by Evadne Wu on 10/7/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (IRLifetimeHelperAdditions)

- (void) irPerformOnDeallocation:(void(^)(void))aBlock;
- (NSMutableSet *) irLifetimeHelpers;

@end


@interface IRLifetimeHelper : NSObject

+ (id) helperWithDeallocationCallback:(void(^)(void))aBlock;

@property (nonatomic, readwrite, copy) void (^deallocationCallback)(void);

@end
