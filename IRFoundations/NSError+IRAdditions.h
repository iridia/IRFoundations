//
//  NSError+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/5/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (IRAdditions)

+ (NSError *) irErrorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description reason:(NSString *)reason userInfo:(NSDictionary *)dict;

+ (NSError *) irErrorWithDomain:(NSString *)domain code:(NSInteger)code descriptionLocalizationKey:(NSString *)descriptionKey reasonLocalizationKey:(NSString *)reasonKey userInfo:(NSDictionary *)dict;

@end
