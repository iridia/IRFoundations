//
//  IRManagedObjectContext.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/10/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (IRAdditions)

- (NSManagedObject *) irManagedObjectForURI:(NSURL *)anURI;

@end

@interface IRManagedObjectContext : NSManagedObjectContext

//	Calling this causes the managed object context to register for NSManagedObjectContextDidSave notifications, and on the case that a) the saved context is not itself, and b) the model and persistent store is the same as the listener context, it’ll call -mergeChangesFromManagedObjectContextDidSaveNotification: automatically

//	Note that these methods are NOT thread safe; you’ll have to call them on the thread that initializes the context

- (void) irPerform:(void(^)(void))block waitUntilDone:(BOOL)sync;

- (void) irBeginMergingFromSavesAutomatically;
- (void) irStopMergingFromSavesAutomatically;
- (BOOL) irIsMergingFromSavesAutomatically;

- (void) irMakeAutoMerging;

@end
