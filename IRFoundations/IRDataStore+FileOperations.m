//
//  IRDataStore+FileOperations.m
//  IRFoundations
//
//  Created by Evadne Wu on 5/15/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
	#import <UIKit/UIKit.h>
	#import <MobileCoreServices/MobileCoreServices.h>
#else
	#import <CoreServices/CoreServices.h>
#endif

#import "IRDataStore+FileOperations.h"
#import "IRManagedObjectContext.h"

@implementation IRDataStore (FileOperations)

- (NSString *) persistentFileURLBasePath {

	//	Here’s a fundamental assumption: app bundle won’t get moved when the app is running.
	//	If that fails, don’t cache the path.

	static NSString * path;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{

		path = [(NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
	
	});

	return path;

}

- (NSString *) temporaryFileURLBasePath {

//	Here’s a fundamental assumption: app bundle won’t get moved when the app is running.
	//	If that fails, don’t cache the path.

	static NSString * path;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{

		path = NSTemporaryDirectory();
		
	});

	return path;


}

- (NSString *) relativePathWithBasePath:(NSString *)basePath filePath:(NSString *)filePath {

	if (![filePath hasPrefix:basePath])
		return filePath;
	
	return [filePath substringFromIndex:[basePath length]];
	
}

- (NSString *) absolutePathWithBasePath:(NSString *)basePath filePath:(NSString *)filePath {

	return [[basePath stringByAppendingPathComponent:filePath] stringByExpandingTildeInPath];

}

- (NSURL *) oneUsePersistentFileURL {

	return [NSURL fileURLWithPath:[[self persistentFileURLBasePath] stringByAppendingPathComponent:IRDataStoreNonce()]];

}

- (NSURL *) oneUseTemporaryFileURL {

	return [NSURL fileURLWithPath:[[self temporaryFileURLBasePath] stringByAppendingPathComponent:IRDataStoreNonce()]];

}

- (NSURL *) persistentFileURLForData:(NSData *)data {

	return [self persistentFileURLForData:data extension:nil];
	
}

- (NSURL *) persistentFileURLForData:(NSData *)data extension:(NSString *)fileExtension {

	NSURL *fileURL = [self oneUsePersistentFileURL];
	
	if (fileExtension)
		fileURL = [fileURL URLByAppendingPathExtension:fileExtension];
	
	[data writeToURL:fileURL atomically:NO];
	
	return fileURL;	

}

- (NSURL *) persistentFileURLForFileAtURL:(NSURL *)aURL {

	NSFileManager *fileManager = [NSFileManager defaultManager];
	
#ifndef NS_BLOCK_ASSERTIONS
{	
	BOOL isDirectoryURL = NO;
	NSAssert2(([fileManager fileExistsAtPath:[aURL path] isDirectory:&isDirectoryURL] && !isDirectoryURL), @"URL %@ must exist%@.", aURL, (isDirectoryURL ? @" and should not be a directory" : @""));
};
#endif
	
	NSURL *fileURL = [self oneUsePersistentFileURL];
	fileURL = [NSURL fileURLWithPath:[[fileURL path] stringByAppendingPathExtension:[[aURL path] pathExtension]]];
	
	NSError *error = nil;
	if ([fileManager createDirectoryAtPath:[[aURL path] stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:&error])
	if ([fileManager copyItemAtURL:aURL toURL:fileURL error:&error])
		return fileURL;
		
	NSLog(@"%s: Error copying from %@ to %@: %@", __PRETTY_FUNCTION__, aURL, fileURL, error);
	return nil;

}

- (NSURL *) persistentFileURLForFileAtPath:(NSString *)aPath {
	return [self persistentFileURLForFileAtURL:[NSURL fileURLWithPath:aPath]];
}

- (NSManagedObject *) updateObjectAtURI:(NSURL *)anObjectURI inContext:(NSManagedObjectContext *)aContext takingBlobFromTemporaryFile:(NSString *)aPath usingResourceType:(NSString *)utiType forKeyPath:(NSString *)fileKeyPath matchingURL:(NSURL *)anURL forKeyPath:(NSString *)urlKeyPath {

	NSCParameterAssert(anObjectURI);
	NSCParameterAssert(aPath);
	NSCParameterAssert(fileKeyPath);
	NSCParameterAssert(anURL);
	NSCParameterAssert(urlKeyPath);
		
	NSManagedObjectContext * const context = ((^ {
	
		if (aContext)
			return aContext;
		
		NSManagedObjectContext * const returnedContext = [self disposableMOC];
		returnedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
		return returnedContext;
	
	})());

	NSCParameterAssert(context);
	
	@try {
	
		NSManagedObject * const object = [context irManagedObjectForURI:anObjectURI];
		if ([self updateObject:object inContext:context takingBlobFromTemporaryFile:aPath usingResourceType:utiType forKeyPath:fileKeyPath matchingURL:anURL forKeyPath:urlKeyPath])
			return object;
		
	} @catch (NSException *e) {
	
		NSLog(@"%s: %@", __PRETTY_FUNCTION__, e);
	
	};
	
	return nil;

}

- (BOOL) updateObject:(NSManagedObject *)anObject inContext:(NSManagedObjectContext *)aContext takingBlobFromTemporaryFile:(NSString *)aPath usingResourceType:(NSString *)utiType forKeyPath:(NSString *)fileKeyPath matchingURL:(NSURL *)anURL forKeyPath:(NSString *)urlKeyPath {

	return [self updateObject:anObject inContext:aContext takingBlobFromTemporaryFile:aPath usingResourceType:utiType forKeyPath:fileKeyPath matchingURL:anURL forKeyPath:urlKeyPath error:nil];

}

- (BOOL) updateObject:(NSManagedObject *)anObject inContext:(NSManagedObjectContext *)aContext takingBlobFromTemporaryFile:(NSString *)aPath usingResourceType:(NSString *)utiType forKeyPath:(NSString *)fileKeyPath matchingURL:(NSURL *)anURL forKeyPath:(NSString *)urlKeyPath error:(NSError **)outError {

	@try {
		[anObject primitiveValueForKey:[(NSPropertyDescription *)[[anObject.entity properties] lastObject] name]];
	} @catch (NSException *exception) {
		NSLog(@"Got access exception: %@", exception);
	}

	NSString *currentFilePath = [anObject valueForKey:fileKeyPath];
	if (![[anObject valueForKey:urlKeyPath] isEqualToString:[anURL absoluteString]]) {
		
		if (outError)
			*outError = [NSError errorWithDomain:@"com.iridia.dataStore" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
				@"Underlying object has changed URL value, unsafe to assign blob", NSLocalizedDescriptionKey,
			nil]];
		
		return NO;	//	URL empty
		
	}
	
	NSURL *fileURL = [self persistentFileURLForFileAtURL:[NSURL fileURLWithPath:aPath]];
	if (!fileURL) {
		
		if (outError)
			*outError = [NSError errorWithDomain:@"com.iridia.dataStore" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
				@"Incoming persistent file URL is ultimately transformed to nil", NSLocalizedDescriptionKey,
			nil]];
		
		return NO;
		
	}
	
	NSString *preferredExtension = nil;
	if (utiType)
		preferredExtension = (__bridge_transfer NSString *)(UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)utiType, kUTTagClassFilenameExtension));
	
	if (preferredExtension) {
		
		NSURL *newFileURL = [NSURL fileURLWithPath:[[[fileURL path] stringByDeletingPathExtension] stringByAppendingPathExtension:preferredExtension]];
		
		NSError *movingError = nil;
		BOOL didMove = [[NSFileManager defaultManager] moveItemAtURL:fileURL toURL:newFileURL error:&movingError];
		if (!didMove) {
			
			if (outError)
				*outError = [NSError errorWithDomain:@"com.iridia.dataStore" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
					@"Could not rename the underlying persistent file", NSLocalizedDescriptionKey,
				nil]];
			
			return NO;
			
		}
			
		fileURL = newFileURL;
		
	}
	
	[anObject setValue:[fileURL path] forKey:fileKeyPath];
	
	return YES;

}

@end
