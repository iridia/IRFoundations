//
//  IRDataStore+Metadata.m
//  IRFoundations
//
//  Created by Evadne Wu on 5/30/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRDataStore+Metadata.h"

@implementation IRDataStore (Metadata)

- (NSDictionary *) metadataForPersistentStore:(NSPersistentStore *)store coordinator:(NSPersistentStoreCoordinator *)psc {

	if (!psc) {
		
		psc = self.persistentStoreCoordinator;
	
	}
	
	if (!store) {
	
		NSArray *stores = psc.persistentStores;
		
		if ([stores count])
			store = [stores objectAtIndex:0];
	
	}
	
	return [psc metadataForPersistentStore:store];

}

- (void) setMetadata:(NSDictionary *)metadata forPersistentStore:(NSPersistentStore *)store coordinator:(NSPersistentStoreCoordinator *)psc {

	if (!psc) {
		
		psc = self.persistentStoreCoordinator;
	
	}
	
	if (!store) {
	
		NSArray *stores = psc.persistentStores;
		
		if ([stores count])
			store = [stores objectAtIndex:0];
	
	}
	
	[psc setMetadata:metadata forPersistentStore:store];
	
	[[self disposableMOC] save:nil];

}

- (NSDictionary *) metadata {

	return [self metadataForPersistentStore:nil coordinator:nil];
	
}

- (void) setMetadata:(NSDictionary *)metadata {

	[self setMetadata:metadata forPersistentStore:nil coordinator:nil];

}

- (id) metadataForKey:(id)key {

	return [[self metadata] objectForKey:key];

}

- (void) setMetadata:(id)object forKey:(id)key {

	NSMutableDictionary *md = [[self metadata] mutableCopy];
	
	if (object) {
	
		if (![[md objectForKey:key] isEqual:object]) {
			[md setObject:object forKey:key];
			[self setMetadata:md];
		}
	
	} else {

		if (![[md objectForKey:key] isEqual:object]) {
			[md removeObjectForKey:key];
			[self setMetadata:md];
		}
	
	}
	

}

@end
