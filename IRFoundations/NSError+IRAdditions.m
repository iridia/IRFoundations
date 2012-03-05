//
//  NSError+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 3/5/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSError+IRAdditions.h"

@implementation NSError (IRAdditions)

+ (NSError *) irErrorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description reason:(NSString *)reason userInfo:(NSDictionary *)dict {

	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	
	if (description)
		[userInfo setObject:description forKey:NSLocalizedDescriptionKey];
	
	if (reason)
		[userInfo setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
	
	if (dict)
		[userInfo addEntriesFromDictionary:dict];
	
	return [NSError errorWithDomain:domain code:code userInfo:userInfo];

}

+ (NSError *) irErrorWithDomain:(NSString *)domain code:(NSInteger)code descriptionLocalizationKey:(NSString *)descriptionKey reasonLocalizationKey:(NSString *)reasonKey userInfo:(NSDictionary *)dict {

	return [self irErrorWithDomain:domain code:code description:NSLocalizedString(descriptionKey, nil) reason:NSLocalizedString(reasonKey, nil) userInfo:dict];

}

@end
