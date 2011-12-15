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
#endif
#import <CoreData/CoreData.h>

//	This class is the initial implementation for the application’s data store.
//	To gain persistence and access the store, invoke the class method +defaultStore.

@interface IRDataStore : NSObject

+ (IRDataStore *) defaultStore;

- (IRDataStore *) initWithManagedObjectModel:(NSManagedObjectModel *)model;
- (NSManagedObjectModel *) defaultManagedObjectModel;
- (NSURL *) defaultPersistentStoreURL;

- (NSManagedObjectContext *) defaultAutoUpdatedMOC;
- (NSManagedObjectContext *) disposableMOC;

//	Internally used Core Data stuff
@property (nonatomic, readonly, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//	The “emperor” context
@property (nonatomic, readonly, retain) NSManagedObjectContext *managedObjectContext;


//	Common file operations.
//	-oneUsePersistentFileURL returns something with an UDID embedded
//	Other methods are conveniences

- (NSURL *) oneUsePersistentFileURL;
- (NSURL *) persistentFileURLForData:(NSData *)data; // no extension
- (NSURL *) persistentFileURLForData:(NSData *)data extension:(NSString *)fileExtension;
- (NSURL *) persistentFileURLForFileAtURL:(NSURL *)aURL;
- (NSURL *) persistentFileURLForFileAtPath:(NSString *)aPath;


@property (nonatomic, readwrite, retain) NSString *persistentStoreName; //	Defaults to the name of the application if nil

@end


extern NSString * IRDataStoreTimestamp (void);
extern NSString * IRDataStoreNonce (void);
