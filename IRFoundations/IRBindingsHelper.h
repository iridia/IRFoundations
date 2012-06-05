//
//  IRBindingsHelper.h
//  IRFoundations
//
//  Created by Evadne Wu on 5/23/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRBindingsHelper : NSObject

@property (nonatomic, readwrite, weak) id owner;

- (void) irBind:(NSString *)aKeyPath toObject:(id)anObservedObject keyPath:(NSString *)remoteKeyPath options:(NSDictionary *)options;
- (void) irUnbind:(NSString *)aKeyPath;

@end
