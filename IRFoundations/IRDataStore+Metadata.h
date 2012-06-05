//
//  IRDataStore+Metadata.h
//  IRFoundations
//
//  Created by Evadne Wu on 5/30/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRDataStore.h"

@interface IRDataStore (Metadata)

- (NSDictionary *) metadataForPersistentStore:(NSPersistentStore *)store coordinator:(NSPersistentStoreCoordinator *)coordinator;
- (void) setMetadata:(NSDictionary *)metadata forPersistentStore:(NSPersistentStore *)store coordinator:(NSPersistentStoreCoordinator *)coordinator;;

- (NSDictionary *) metadata;
- (void) setMetadata:(NSDictionary *)metadata;

- (id) metadataForKey:(id)key;
- (void) setMetadata:(id)object forKey:(id)key;

@end
