//
//  IRManagedObject.m
//  IRFoundations
//
//  Created by Evadne Wu on 1/11/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRManagedObject.h"
#import "IRNoOp.h"

@implementation IRManagedObject

- (void) awakeFromFetch {

	[super awakeFromFetch];
	[self irAwake];

}

- (void) awakeFromInsert {

	[super awakeFromInsert];
	[self irAwake];

}

- (void) irAwake {

	//	?

}

+ (NSArray *) insertOrUpdateObjectsIntoContext:(NSManagedObjectContext *)context withExistingProperty:(NSString *)managedObjectKeyPath matchingKeyPath:(NSString *)dictionaryKeyPath ofRemoteDictionaries:(NSArray *)dictionaries {

	if (!dictionaries || [dictionaries isEqual:[NSNull null]] || ([dictionaries count] == 0))
		return nil;
	
	if (!managedObjectKeyPath || !dictionaryKeyPath) {
		
		return [dictionaries irMap: ^ (NSDictionary *configurationDictionary, NSUInteger index, BOOL *stop) {
		
			//	Bad things always happen
		
			if (![configurationDictionary isKindOfClass:[NSDictionary class]])
				return (id)nil;
			
			return (id)[self objectInsertingIntoContext:context withRemoteDictionary:configurationDictionary];
			
		}];
		
	}
		
	dictionaries = [dictionaries irMap:^id(id inObject, NSUInteger index, BOOL *stop) {
		
		if ([inObject isKindOfClass:[NSDictionary class]])
			return inObject;
		
		NSLog(@"Warning: Object %@ at index %i is not a dictionary, skipping.", inObject, index);
		return nil;
		
	}];

	
	__block NSMutableArray *returnedEntities = nil;
	
	@autoreleasepool {
    
		NSError *error = nil;
		NSArray *existingEntities = [context executeFetchRequest:(( ^ {

			NSFetchRequest *returnedRequest = [[NSFetchRequest alloc] init];

			[returnedRequest setEntity:[NSEntityDescription entityForName:[self coreDataEntityName] inManagedObjectContext:context]];
			
			[returnedRequest setPredicate:[NSPredicate predicateWithFormat:
			
				@"(%K IN %@)", 
			
				managedObjectKeyPath, 
				[[dictionaries irMap:IRArrayMapCallbackMakeWithKeyPath(dictionaryKeyPath)] irMap:IRArrayMapCallbackMakeNullFilter()]
				
			]];
			
			[returnedRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:managedObjectKeyPath ascending:YES]]];
			
			[returnedRequest setReturnsObjectsAsFaults:NO];
			
			return returnedRequest;
		
		})()) error:&error];
		
		if (!existingEntities)
			return nil;
		
		NSUInteger existingEntitiesCount = [existingEntities count];
		__block NSUInteger currentEntityIndex = -1;
		IRManagedObject *currentEntity = (existingEntitiesCount > 0) ? [existingEntities objectAtIndex:0] : nil;

		id (^nextEntity)() = ^ {
		
			if (!currentEntity)
			return (id)nil;

			currentEntityIndex++;
			
			if (currentEntityIndex == existingEntitiesCount)
			return (id)nil;
			
			return (id)[existingEntities objectAtIndex:currentEntityIndex];
			
		};


		NSComparisonResult (^compare) (id, id) = ^ (id inEntity, id inRemoteDictionary) {
		
			return [[inEntity valueForKey:managedObjectKeyPath] compare:[inRemoteDictionary valueForKeyPath:dictionaryKeyPath]];
		
		};
		
		returnedEntities = [dictionaries mutableCopy];
		NSArray *sortedRemoteDictionaries = [dictionaries sortedArrayUsingComparator:irComparatorMakeWithNodeKeyPath(dictionaryKeyPath)];
		
		
		NSMutableArray *updatedOrInsertedReps = [NSMutableArray array];
		
		
	//	The remote dictionaries are sorted by the value at a particular key path.  There may be duplicates.
	//	Duplicates get wrapped into an array containing every representation.

		__block NSMutableArray *currentWrapperArray = nil;
		
		NSArray *uniqueValues = [[sortedRemoteDictionaries irMap:^(id inObject, NSUInteger index, BOOL *stop) {
		
			return [inObject valueForKeyPath:dictionaryKeyPath];
		
		}] irMap:IRArrayMapCallbackMakeNullFilter()];
		
		NSMutableArray *unusedRemoteDictionaries = [sortedRemoteDictionaries mutableCopy];
		
		[uniqueValues enumerateObjectsUsingBlock: ^ (id currentUniqueValue, NSUInteger idx, BOOL *stop) {
		
			id currentObject = [sortedRemoteDictionaries objectAtIndex:idx];
		
			if (idx > 0)
			if ([currentUniqueValue isEqual:[uniqueValues objectAtIndex:(idx - 1)]]) {

				[currentWrapperArray addObject:currentObject];
				[unusedRemoteDictionaries removeObject:currentObject];
				return;
			
			}
		
			NSMutableArray *wrapperArray = [NSMutableArray array];
			[updatedOrInsertedReps addObject:wrapperArray];
			[wrapperArray addObject:currentObject];
			[unusedRemoteDictionaries removeObject:currentObject];
			
			currentWrapperArray = wrapperArray;
		
		}];
		

		for (NSDictionary *anUnusedRemoteDictionary in unusedRemoteDictionaries)
			[updatedOrInsertedReps addObject:[NSArray arrayWithObject:anUnusedRemoteDictionary]];
		
		//	There is a circumstance, where the multiple remote dictionaries can have a same value at dictionaryKeyPath
		
		for (NSArray *currentDictionaryWrapper in updatedOrInsertedReps) {
		
			id currentDictionary = [currentDictionaryWrapper objectAtIndex:0];
		
			if ([currentDictionary isEqual:[NSNull null]])
			continue;
			
		//	When the dictionary has a marker that is ahead of the entity, move on to the next entity
			
			if (currentEntity)
			while (compare(currentEntity, currentDictionary) == NSOrderedAscending) {
			
				currentEntity = nextEntity();
				
				if (!currentEntity)
				break;
						
			}
			
			
		//	The marker of the dictionary is guaranteed to match, or fall behind the current entity
		
			IRManagedObject *touchedEntity = nil;
			
			
			NSDictionary *configurationDictionary = (( ^ {
			
				if ([currentDictionaryWrapper count] == 1)
				return currentDictionary;
			
				NSMutableDictionary *returnedDictionary = [currentDictionary mutableCopy];
				
				[currentDictionaryWrapper enumerateObjectsUsingBlock: ^ (NSDictionary *aDictionary, NSUInteger idx, BOOL *stop) {
		
					[returnedDictionary addEntriesFromDictionary:aDictionary];
		
				}];
				
				return (id)returnedDictionary;
			
			})());
			
			
		//	Compare only the master key path.  Since only the master is compared there is only need to make sure we touch the entity only ONCE per loop, hence the composited dictionary is used to avoid potentially very costly object configuration.
			
			if ((currentEntity != nil) && (compare(currentEntity, currentDictionary) == NSOrderedSame)) {
			
				touchedEntity = currentEntity;
				[touchedEntity configureWithRemoteDictionary:configurationDictionary];
			
			} else {
			
				touchedEntity = [self objectInsertingIntoContext:context withRemoteDictionary:configurationDictionary];
			
			}
			
			
		//	If there are multiple representations, use them up
		
			NSIndexSet *indexes = [returnedEntities indexesOfObjectsPassingTest: ^ (id obj, NSUInteger idx, BOOL *stop) {
			
				if (![obj isKindOfClass:[NSDictionary class]])
					return NO;
			
				return [[obj valueForKeyPath:dictionaryKeyPath] isEqual:[currentDictionary valueForKeyPath:dictionaryKeyPath]];
			
			}];
			
			
			
			[indexes enumerateIndexesUsingBlock: ^ (NSUInteger idx, BOOL *stop) {

				[returnedEntities replaceObjectAtIndex:idx withObject:touchedEntity];
			
			}];
			
			if (![indexes count]) {
			
				NSUInteger foundIndex = [returnedEntities indexOfObjectIdenticalTo:currentDictionary];
				if (foundIndex != NSNotFound)
					[returnedEntities replaceObjectAtIndex:foundIndex withObject:touchedEntity];
			}
			
		}
		
		return returnedEntities;

	}

}


+ (NSArray *) insertOrUpdateObjectsUsingContext:(NSManagedObjectContext *)context withRemoteResponse:(NSArray *)inRemoteDictionaries usingMapping:(NSDictionary *)remoteKeyPathsToClassNames options:(IRManagedObjectOptions)options {

	if (![inRemoteDictionaries count])
		return [NSArray array];
	
	@autoreleasepool {
	
		if (!remoteKeyPathsToClassNames)
			remoteKeyPathsToClassNames = [self defaultHierarchicalEntityMapping];
		
		NSArray *usedRemoteDictionaries = [inRemoteDictionaries irMap: ^ (NSDictionary *aRepresentation, NSUInteger index, BOOL *stop) {
			return [self transformedRepresentationForRemoteRepresentation:aRepresentation];
		}];

		NSString * const localKeyPath = [self keyPathHoldingUniqueValue];
		NSString * const remoteKeyPath = localKeyPath ? [[[self remoteDictionaryConfigurationMapping] allKeysForObject:localKeyPath] objectAtIndex:0] : nil;
		
		NSArray * const baseEntities = [self insertOrUpdateObjectsIntoContext:context withExistingProperty:localKeyPath matchingKeyPath:remoteKeyPath ofRemoteDictionaries:usedRemoteDictionaries];
		NSParameterAssert(baseEntities);
		
		NSDictionary *baseEntityRelationships = [[[[[context persistentStoreCoordinator] managedObjectModel] entitiesByName] objectForKey:[self coreDataEntityName]] relationshipsByName];
		
		
		for (NSString *rootRemoteKeyPath in remoteKeyPathsToClassNames) {
		
			Class nodeEntityClass = NSClassFromString([remoteKeyPathsToClassNames objectForKey:rootRemoteKeyPath]);
			NSString * const rootLocalKeyPath = [[self remoteDictionaryConfigurationMapping] objectForKey:rootRemoteKeyPath];
			
			//	Skip if the local key path is not mappable
			if (!rootLocalKeyPath) {
			
				if (![self skipsNonexistantRemoteKey]) {
				
					[NSException raise:NSInternalInconsistencyException format:@"A remote mapping %@ -> %@ is not found, using mapping %@", rootRemoteKeyPath, NSStringFromClass(nodeEntityClass), [self remoteDictionaryConfigurationMapping]];
				
				}
				
				continue;
				
			}
			
			NSRelationshipDescription *relationship = [baseEntityRelationships objectForKey:rootLocalKeyPath];
			BOOL const relationIsToMany = [relationship isToMany];
			BOOL const relationIsOrdered = [relationship isOrdered];
			BOOL const usesIndividualAdd = relationIsToMany && !relationIsOrdered && (options & IRManagedObjectOptionIndividualOperations);
			
			NSArray *nodeRepresentations = [usedRemoteDictionaries irMap:IRArrayMapCallbackMakeWithKeyPath(rootRemoteKeyPath)];
			NSArray *entityRepresentations = [nodeRepresentations irFlatten];
			
			NSArray *nodeEntities = [nodeEntityClass insertOrUpdateObjectsUsingContext:context withRemoteResponse:entityRepresentations usingMapping:[nodeEntityClass defaultHierarchicalEntityMapping] options:options];
			
			__block NSInteger consumedNodeEntities = 0;
			
			[baseEntities enumerateObjectsUsingBlock: ^ (IRManagedObject *baseObject, NSUInteger index, BOOL *stop) {
			
				NSParameterAssert([baseObject isKindOfClass:[IRManagedObject class]]);
			
				NSUInteger relatedNodesCount = irCount([nodeRepresentations objectAtIndex:index], 0);
				
				if ((relatedNodesCount == 0) || (relatedNodesCount == NSNotFound))
					return;
				
				if ([rootLocalKeyPath isEqual:[NSNull null]] || !rootLocalKeyPath)
					[NSException raise:NSInternalInconsistencyException format:@"Local key path for remote key path %@ can’t be null or nil.", rootRemoteKeyPath];
				
				NSArray *relatedEntities = [nodeEntities subarrayWithRange:NSMakeRange(consumedNodeEntities, relatedNodesCount)];
				
				NSParameterAssert(rootLocalKeyPath);
				
				[baseObject willChangeValueForKey:rootLocalKeyPath];
				
				if (relationIsToMany) {
				
					if (relationIsOrdered) {
					
						NSMutableOrderedSet *mos = [baseObject mutableOrderedSetValueForKeyPath:rootLocalKeyPath];
						
						[mos removeAllObjects];
						[mos addObjectsFromArray:relatedEntities];
					
					} else {
					
						NSMutableSet *ms = [baseObject mutableSetValueForKeyPath:rootLocalKeyPath];
				
						if (usesIndividualAdd) {
					
							[ms removeAllObjects];
					
							for (id anObject in relatedEntities)
								[[baseObject mutableSetValueForKeyPath:rootLocalKeyPath] addObject:anObject];
							
						} else {
						
							//	Bad form: Losing implicit ordering this way
						
							[ms setSet:[NSSet setWithArray:relatedEntities]];
						
						}
					
					}
					
				} else {
				
					[baseObject setValue:[relatedEntities objectAtIndex:0] forKeyPath:rootLocalKeyPath];
				
				}
				
				[baseObject didChangeValueForKey:rootLocalKeyPath];
				
				consumedNodeEntities += relatedNodesCount;
				
				if (!(relationIsToMany || (!relationIsToMany && (relatedNodesCount == 1))))
				if ([[NSSet setWithArray:nodeEntities] count] > 1)
					[NSException raise:NSInternalInconsistencyException format:@"A to-one relationship can’t have multiple related entities."];
			
			}];
			
			if (consumedNodeEntities != [nodeEntities count])
				[NSException raise:NSInternalInconsistencyException format:@"%s expects to exhaust all entities.", __PRETTY_FUNCTION__];
			
		}
	
		return baseEntities;
	
	}

}





+ (NSString *) keyPathHoldingUniqueValue {

	return nil;

}

+ (NSDictionary *) defaultHierarchicalEntityMapping {

	return nil;

}





+ (NSString *) coreDataEntityName {

	return NSStringFromClass([self class]);

}

+ (id) objectInsertingIntoContext:(NSManagedObjectContext *)inContext withRemoteDictionary:(NSDictionary *)inDictionary {

	if (inDictionary)
		NSCParameterAssert([inDictionary isKindOfClass:[NSDictionary class]]);

	IRManagedObject *object = [[self alloc] initWithEntity:[NSEntityDescription entityForName:[self coreDataEntityName] inManagedObjectContext:inContext] insertIntoManagedObjectContext:inContext];
		
	if (!object)
		return nil;
	
	if (inDictionary)
		[object configureWithRemoteDictionary:inDictionary];
	
	return object;

}





+ (NSEntityDescription *) entityDescriptionForContext:(NSManagedObjectContext *)aContext {

	return [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aContext];

}





+ (NSDictionary *) transformedRepresentationForRemoteRepresentation:(NSDictionary *)incomingRepresentation {

	return incomingRepresentation;

}

@end






