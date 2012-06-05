//
//  IRBindingsHelperContext.h
//  IRFoundations
//
//  Created by Evadne Wu on 5/23/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRBindings.h"

@interface IRBindingsHelperContext : NSObject

- (id) initWithSource:(id)source keyPath:(NSString *)sourceKeyPath target:(id)target keyPath:(NSString *)targetKeyPath options:(NSDictionary *)options;

@end
