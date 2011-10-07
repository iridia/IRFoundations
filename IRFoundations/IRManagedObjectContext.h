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

@end
