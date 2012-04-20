//
//  NSBundle+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/23/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (IRAdditions)

+ (NSBundle *) irFrameworkBundleWithName:(NSString *)name;
+ (NSBundle *) irFrameworkBundleWithIdentifier:(NSString *)identifier;

- (NSString *) displayVersionString;
- (NSString *) debugVersionString;

@end
