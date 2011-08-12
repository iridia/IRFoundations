//
//  IRManagedObject.h
//  Milk
//
//  Created by Evadne Wu on 1/11/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Foundation+IRAdditions.h"
#import "CoreData+IRAdditions.h"
#import "IRNoOp.h"


#if 0

	#define IRMOLog( s, ... ) NSLog( @"<%s : (%d)> %@",__FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#else

	#define IRMOLog( s, ... ) 

#endif


@interface IRManagedObject : NSManagedObject

//	Notes:
//	Remember that you’ll have to also update your data model, so the custom class is used on your entity


+ (NSArray *) insertOrUpdateObjectsIntoContext:(NSManagedObjectContext *)inContext withExistingProperty:(NSString *)inLocalMarkerKeyPath matchingKeyPath:(NSString *)inRemoteMarkerKeyPath ofRemoteDictionaries:(NSArray *)inRemoteDictionaries;

//	Like INSERT … ON DUPLICATE KEY UPDATE.  If existing value at key path matches the remote key path, the existing object and the remote representation dictionary is thought as two different snapshots of a logically single object, whose properties will be updated using the remote representation.

//	The returned array contains one object per remote representation.  Some of them could be old but updated objects, other being newly inserted objects.  The idea is that you’ll fix relationships using the returned array, if necessary.

//	The order of the returned array is guaranteed to be of the same order as the incoming remote dictionaries are ordered.

//	The values that the local and remote key paths point to should always respond to -compare:.


+ (NSArray *) insertOrUpdateObjectsUsingContext:(NSManagedObjectContext *)inContext withRemoteResponse:(NSArray *)inRemoteDictionaries usingMapping:(NSDictionary *)inRemoteKeyPathsToIRManagedObjectSubclasses options:(int)aBitMask;

//	This is a higher-level wrapper dealing with circumstances where an object representation contains other representations that are also of interest to the developer.

//	For example:
//	{ id: 20, related: { id: 201, title: "Hi" }, title: "Ho" }
//	
//	Where the “related” object is a representation that another IRManagedObject subclass understands

//	This method can potentially generate a lot of I/O.

//	Note, that “related” is an object here.  This method also works when the node is an collection.
//	Collection traversal is implemented using fast enumeration.
//	The order of the collection is not respected.

//	Example:
//	
//	[MLGoogleReaderFeed insertOrUpdateObjectsUsingContext:[[self newManagedObjectContext] autorelease] withRemoteResponse:[inResponseOrNil objectForKey:@"subscriptions"] usingMapping:[NSDictionary dictionaryWithObjectsAndKeys:
//	
//		[MLGoogleReaderUser class], @"user",
//		[MLGoogleReaderFeed class], @"labels",
//	
//	nil] options:nil];

//	N.B. that usingMapping: takes a dictionary, whose keys are remote key paths.
//	For example, if your subclass mirrors “id” to “identifier”, the dictionary keys the class to “id”.

//	By default, if the representation is found to represent an existing object, and that object has to-many relationships, all the previous related objects are replaced by the new ones.  Pass kIRManagedObjectMergeRelatedObjects as a bit-mask to options, so the new objects are added to the relationship but the old ones are retained.


+ (NSString *) coreDataEntityName;

//	Default returns NSStringFromClass([self class]);


+ (NSString *) keyPathHoldingUniqueValue;

//	This method defaults to nil.
//	Return a NSString, so -insertOrUpdateObjectsUsingContext:withRemoteResponse:usingMapping: works.


+ (NSDictionary *) defaultHierarchicalEntityMapping;

//	Returns nil by default.
//	Returning a dictionary of attribute names to class name strings, to allow hierarchical transforms


+ (id) objectInsertingIntoContext:(NSManagedObjectContext *)inContext withRemoteDictionary:(NSDictionary *)inDictionary;

//	Makes a new object, inserting into the context, then call its -configureWithRemoteDictionary:.


+ (NSEntityDescription *) entityDescriptionForContext:(NSManagedObjectContext *)aContext;

@end





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


@end





@interface IRManagedObject (DelayedPerforming)

- (void) performSafely:(void(^)(void))aBlock;
- (void) performSafely:(void(^)(void))aBlock withExceptionHandler:(BOOL(^)(NSException *e))exceptionHandlerOrNil;

//	Unsolicited Core Data operations, like delayed performing, can fail if the object is made inaccessible, etc.  In that case, use of these helper methods will simply cancel the operation.  The exception handler block returns a BOOL.  If YES, the exception does not propagate; if NO, the exception is re-thrown.

@end




