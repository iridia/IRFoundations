//
//  IRDataStore.h
//  IRFoundations
//
//  Created by Evadne Wu on 7/21/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IRManagedObjectContext;
@interface IRDataStore : NSObject

+ (IRDataStore *) defaultStore;

- (IRDataStore *) initWithManagedObjectModel:(NSManagedObjectModel *)model;

- (NSManagedObjectModel *) defaultManagedObjectModel;

- (NSURL *) defaultPersistentStoreURL;	//	Root implementation looks at persistentStoreName

- (NSManagedObjectContext *) newContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type;
- (NSManagedObjectContext *) defaultAutoUpdatedMOC;
- (NSManagedObjectContext *) disposableMOC;

- (void) performBlock:(void(^)(void))block waitUntilDone:(BOOL)waitsUntilDone;

@property (nonatomic, readonly, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readwrite, copy) NSString *persistentStoreName; //	Defaults to the name of the application if nil

@end


extern NSString * IRDataStoreTimestamp (void);
extern NSString * IRDataStoreNonce (void);

#import "IRDataStore+FileOperations.h"
