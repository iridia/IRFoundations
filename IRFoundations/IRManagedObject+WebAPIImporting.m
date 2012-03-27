//
//  IRManagedObject+WebAPIImporting.m
//  IRFoundations
//
//  Created by Evadne Wu on 3/26/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRManagedObject+WebAPIImporting.h"


@implementation IRManagedObject (WebAPIImporting)

+ (NSDictionary *) remoteDictionaryConfigurationMapping {

	return nil;

}

+ (id) transformedValue:(id)aValue fromRemoteKeyPath:(NSString *)aRemoteKeyPath toLocalKeyPath:(NSString *)aLocalKeyPath {

	return aValue;

}

+ (id<NSObject>) placeholderForNonexistantKey {

	return nil;

}

+ (id<NSObject>) placeholderForNullValue {

	return nil;

}

+ (BOOL) skipsNonexistantRemoteKey {

	return [[self placeholderForNonexistantKey] isEqual:[IRNoOp noOp]];

}

+ (BOOL) skipsNullValue {

	return [[self placeholderForNullValue] isEqual:[IRNoOp noOp]];	

}

- (void) configureWithRemoteDictionary:(NSDictionary *)inDictionary {

	NSDictionary *configurationMapping = [[self class] remoteDictionaryConfigurationMapping];

	if (!configurationMapping)
	return;
	
	NSAssert([configurationMapping isKindOfClass:[NSDictionary class]], @"-configureWithDictionary found +remoteDictionaryConfigurationMapping, unfortunately -isKindOfClass: disagrees with its type.");
	
	BOOL skipsNonexistantRemoteKey = [[self class] skipsNonexistantRemoteKey];
	id nonexistantRemoteKeyPlaceholder = [[self class] placeholderForNonexistantKey];
	
	BOOL skipsNullValue = [[self class] skipsNullValue];
	id nullValuePlaceholder = [[self class] placeholderForNullValue];
	
	for (id aRemoteKeyPath in configurationMapping) {
	
		id aRemoteValueOrNil = [inDictionary valueForKeyPath:aRemoteKeyPath];
	
		//	A remote dictionary at the end means that it is a composite representation, not to be assigned as a property value
		if ([aRemoteValueOrNil isKindOfClass:[NSDictionary class]])
			continue;
		
		id aLocalKeyPathOrNSNull = [configurationMapping objectForKey:aRemoteKeyPath];
		
		if ([aLocalKeyPathOrNSNull isEqual:[NSNull null]])
		continue;
		
		NSAssert([aLocalKeyPathOrNSNull isKindOfClass:[NSString class]], @"in +remoteDictionaryConfigurationMapping, the local key path must be a NSString, or [NSNull null].");
		NSString *aLocalKeyPath = (NSString *)aLocalKeyPathOrNSNull;
		
		id committedValue = aRemoteValueOrNil;
		
		if (!aRemoteValueOrNil) {
		
			if (skipsNonexistantRemoteKey)
			continue;
			
			committedValue = nonexistantRemoteKeyPlaceholder;
		
		} else if ([aRemoteValueOrNil isEqual:[NSNull null]]) {
		
			if (skipsNullValue)
			continue;
			
			committedValue = nullValuePlaceholder;
		
		}
		
	//	If the committed value is actually an array we assume that it’ll be taken care of by insertOrUpdateObjectsUsingContext:withRemoteResponse:usingMapping:options: instead
		
		if (![committedValue isKindOfClass:[NSArray class]]) {
			
			@try {
				[self setValue:[[self class] transformedValue:committedValue fromRemoteKeyPath:aRemoteKeyPath toLocalKeyPath:aLocalKeyPath] forKeyPath:aLocalKeyPath];
			} @catch (NSException *exception) {
				NSLog(@"Exception happened when setting value: %@", exception);
			}
			
		}
			
	}
	
}





- (BOOL) irIsDirectlyRelatedToObject:(NSManagedObject *)anObject {

	//	Since walking indirect relationships is so hard we’re limiting this to direct entities only

	__block BOOL returnedAnswer = NO;

	[self.entity.relationshipsByName enumerateKeysAndObjectsUsingBlock: ^ (NSString *relationshipName, NSRelationshipDescription *relationship, BOOL *stop) {
	
		if (![relationship.entity isEqual:anObject.entity])
			return;
	
		if (relationship.isToMany) {
		
			if ([[self mutableSetValueForKey:relationshipName] containsObject:anObject]) {
			
				returnedAnswer = YES;
				*stop = YES;
				return;
			
			}
		
		} else {
		
			if ([[self valueForKey:relationshipName] isEqual:anObject]) {
			
				returnedAnswer = YES;
				*stop = YES;
				return;
			
			}
		
		}
		
	}];
	
	return returnedAnswer;

}

@end
