//
//  NSDictionary+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSDictionary+IRAdditions.h"

@implementation NSDictionary (IRAdditions)

- (BOOL) irPassesTestSuite:(NSDictionary *)aSuite {

	__block BOOL passes = YES;
	
	[aSuite enumerateKeysAndObjectsUsingBlock: ^ (id key, id obj, BOOL *stop) {
	
		IRDictionaryPairTest aTest = [aSuite objectForKey:key];
		
		if (!aTest || aTest(key, [self objectForKey:key]))
			return;
		
		passes = NO;
		*stop = YES;
		
	}];
	
	return passes;

}

- (NSDictionary *) irDictionaryBySettingObject:(id)anObject forKey:(NSString *)aKey {

	return [self irDictionaryByMergingWithDictionary:[NSDictionary dictionaryWithObject:anObject forKey:aKey]];

}

- (NSDictionary *) irDictionaryByMergingWithDictionary:(NSDictionary *)aDictionary {

	NSMutableDictionary *copy = [self mutableCopy];
	[copy addEntriesFromDictionary:aDictionary];
	
	return copy;

}

@end
