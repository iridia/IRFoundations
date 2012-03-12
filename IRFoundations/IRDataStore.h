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

@property (nonatomic, readwrite, retain) NSString *persistentStoreName; //	Defaults to the name of the application if nil
- (NSURL *) defaultPersistentStoreURL;	//	Root implementation looks at persistentStoreName

- (NSManagedObjectContext *) defaultAutoUpdatedMOC;
- (NSManagedObjectContext *) disposableMOC;


//	Internally used Core Data stuff
@property (nonatomic, readonly, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;


//	Common file operations.
//	-oneUsePersistentFileURL returns something with an UDID embedded
//	Other methods are conveniences

- (NSString *) persistentFileURLBasePath;	//	By default the documents directory
- (NSString *) temporaryFileURLBasePath;	//	By default NSTemporaryDirectory()
- (NSString *) relativePathWithBasePath:(NSString *)basePath filePath:(NSString *)filePath;
- (NSString *) absolutePathWithBasePath:(NSString *)basePath filePath:(NSString *)filePath;


//	Note that everything here returns absolute URLs
//	If you’re storing references to files in the app that probably gets migrated, use transformed relative paths

- (NSURL *) oneUsePersistentFileURL;
- (NSURL *) persistentFileURLForData:(NSData *)data; // no extension
- (NSURL *) persistentFileURLForData:(NSData *)data extension:(NSString *)fileExtension;
- (NSURL *) persistentFileURLForFileAtURL:(NSURL *)aURL;
- (NSURL *) persistentFileURLForFileAtPath:(NSString *)aPath;

- (NSURL *) oneUseTemporaryFileURL;


//	Convenience for updating objects, though they don’t save

- (NSManagedObject *) updateObjectAtURI:(NSURL *)anObjectURI inContext:(NSManagedObjectContext *)aContext takingBlobFromTemporaryFile:(NSString *)aPath usingResourceType:(NSString *)utiType forKeyPath:(NSString *)fileKeyPath matchingURL:(NSURL *)anURL forKeyPath:(NSString *)urlKeyPath;

- (BOOL) updateObject:(NSManagedObject *)anObject inContext:(NSManagedObjectContext *)aContext takingBlobFromTemporaryFile:(NSString *)aPath usingResourceType:(NSString *)utiType forKeyPath:(NSString *)fileKeyPath matchingURL:(NSURL *)anURL forKeyPath:(NSString *)urlKeyPath;

@end


@interface IRDataStore (Deprecated)

- (BOOL) updateObject:(NSManagedObject *)anObject takingBlobFromTemporaryFile:(NSString *)aPath usingResourceType:(NSString *)utiType forKeyPath:(NSString *)fileKeyPath matchingURL:(NSURL *)anURL forKeyPath:(NSString *)urlKeyPath DEPRECATED_ATTRIBUTE;

@end


extern NSString * IRDataStoreTimestamp (void);
extern NSString * IRDataStoreNonce (void);
