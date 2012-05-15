//
//  IRDataStore.h
//  IRFoundations
//
//  Created by Evadne Wu on 7/21/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
	#import <UIKit/UIKit.h>
	#import <MobileCoreServices/MobileCoreServices.h>
#else
	#import <CoreServices/CoreServices.h>
#endif

#import <CoreData/CoreData.h>


//	This class is the initial implementation for the application’s data store.
//	To gain persistence and access the store, invoke the class method +defaultStore.

@interface IRDataStore : NSObject

+ (IRDataStore *) defaultStore;

- (IRDataStore *) initWithManagedObjectModel:(NSManagedObjectModel *)model;

- (NSManagedObjectModel *) defaultManagedObjectModel;

- (NSURL *) defaultPersistentStoreURL;	//	Root implementation looks at persistentStoreName

- (NSManagedObjectContext *) defaultAutoUpdatedMOC;
- (NSManagedObjectContext *) disposableMOC;

- (void) performBlock:(void(^)(void))block waitUntilDone:(BOOL)waitsUntilDone;

@property (nonatomic, readonly, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readwrite, retain) NSString *persistentStoreName; //	Defaults to the name of the application if nil

@end


extern NSString * IRDataStoreTimestamp (void);
extern NSString * IRDataStoreNonce (void);

#import "IRDataStore+FileOperations.h"
