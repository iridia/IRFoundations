//
//  IRManagedObject+WebAPIImporting.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/26/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRManagedObject.h"


@interface IRManagedObject (WebAPIImporting)

- (void) configureWithRemoteDictionary:(NSDictionary *)inDictionary;

//	Takes values from a remote dictionary.  Does not whatsoever change the contents.
//	If +remoteDictionaryConfigurationMapping is implemented, does not return nil, uses the mapping.
//	Otherwise, default implementation does nothing.


+ (NSDictionary *) remoteDictionaryConfigurationMapping;

//	To avoid rolling your own -valueForKeyPath wrappers that avoids [NSNull null] et al, implement +remoteDictionaryConfigurationMapping, whose keys are remote dictionary key path strings, and their values the key path string to the desired value of the local object, that the remote value goes into.

//	If the returned local key path is actually [NSNull null], the value gets ignored.

//	Consider making this method return a static object if necessary.


+ (id) transformedValue:(id)aValue fromRemoteKeyPath:(NSString *)aRemoteKeyPath toLocalKeyPath:(NSString *)aLocalKeyPath;

//	Returns a transformed, if any, or nil, for value at a particular key path.
//	This allows the subclass to do custom value transformation.
//	Placeholders are also transformed.

//	Defaults to the incoming value.  Return [IRNoOp noOp] to do nothing.

//	This is not a replacement for overriding -set<Property>: and implementing custom transformations before calling -setPrimitive<Property>:.  This is for use when the implementations of IRManagedObject+WebAPIImporting is provided in file for another class.


+ (id<NSObject>) placeholderForNonexistantKey;

//	Placeholder value to use if a remote value that is specified within the mapping is not found.
//	e.g., if a key “bogus” is specified in the mapping, but the incoming dictionary does not have it.

//	Defaults to nil.
//	Try [IRNoOp noOp] if you want to skip the key instead of niling or setting the value to [NSNull null].  It is useful to have a no-op, if you will touch the object more than once, and some incoming data is incomplete.


+ (id<NSObject>) placeholderForNullValue;

//	Placeholder value to use if a remote value is [NSNull null].
//	Defaults to nil.
//	Try [IRNoOp noOp] if you want to skip the key instead of niling or setting the value to [NSNull null].


+ (BOOL) skipsNonexistantRemoteKey;
+ (BOOL) skipsNullValue;

//	Introspective.


@end
