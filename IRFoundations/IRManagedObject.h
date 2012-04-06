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


enum IRManagedObjectOptions {
 
	IRManagedObjectOptionIndividualOperations = 1 << 1	//	Individual insertions are slower, but allow per-object overrides for synthesized ordered relationships.
	
}; typedef NSUInteger IRManagedObjectOptions;


@interface IRManagedObject : NSManagedObject

- (void) irAwake;	//	Called in -awakeFromInsert, and -awakeFromFetch

+ (NSEntityDescription *) entityDescriptionForContext:(NSManagedObjectContext *)aContext;


+ (NSArray *) insertOrUpdateObjectsIntoContext:(NSManagedObjectContext *)inContext withExistingProperty:(NSString *)inLocalMarkerKeyPath matchingKeyPath:(NSString *)inRemoteMarkerKeyPath ofRemoteDictionaries:(NSArray *)inRemoteDictionaries;

//	Like INSERT … ON DUPLICATE KEY UPDATE.  If existing value at key path matches the remote key path, the existing object and the remote representation dictionary is thought as two different snapshots of a logically single object, whose properties will be updated using the remote representation.

//	The returned array contains one object per remote representation.  Some of them could be old but updated objects, other being newly inserted objects.  The idea is that you’ll fix relationships using the returned array, if necessary.

//	The order of the returned array is guaranteed to be of the same order as the incoming remote dictionaries are ordered.

//	The values that the local and remote key paths point to should always respond to -compare:.


+ (NSArray *) insertOrUpdateObjectsUsingContext:(NSManagedObjectContext *)inContext withRemoteResponse:(NSArray *)inRemoteDictionaries usingMapping:(NSDictionary *)inRemoteKeyPathsToIRManagedObjectSubclasses options:(IRManagedObjectOptions)aBitMask;

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



+ (NSDictionary *) transformedRepresentationForRemoteRepresentation:(NSDictionary *)incomingRepresentation;
//	Convert identifier fields to object prototypes containing an identifier field, for example.
//	Default implementation returns incoming representation.

@end


#import "IRManagedObject+WebAPIImporting.h"
#import "IRManagedObject+SimulatedOrderedRelationship.h"
