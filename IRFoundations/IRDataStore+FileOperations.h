//
//  IRDataStore+FileOperations.h
//  IRFoundations
//
//  Created by Evadne Wu on 5/15/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRDataStore.h"

@interface IRDataStore (FileOperations)

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

- (BOOL) updateObject:(NSManagedObject *)anObject inContext:(NSManagedObjectContext *)aContext takingBlobFromTemporaryFile:(NSString *)aPath usingResourceType:(NSString *)utiType forKeyPath:(NSString *)fileKeyPath matchingURL:(NSURL *)anURL forKeyPath:(NSString *)urlKeyPath error:(NSError **)outError;


//	Hook for MagicKit integration thru custom application subclass

- (NSString *) pathExtensionForFileAtPath:(NSString *)aPath;

@end
