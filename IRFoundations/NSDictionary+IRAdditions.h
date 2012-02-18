//
//  NSDictionary+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^IRDictionaryPairTest) (id key, id value);


@interface NSDictionary (IRAdditions)

- (BOOL) irPassesTestSuite:(NSDictionary *)aSuite;
//	The suite is a dictionary of keys to IRDictionaryPairTest blocks

- (NSDictionary *) irDictionaryBySettingObject:(id)anObject forKey:(NSString *)aKey;

- (NSDictionary *) irDictionaryByMergingWithDictionary:(NSDictionary *)aDictionary;
//	Currently a shallow merge

@end
