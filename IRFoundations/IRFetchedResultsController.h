//
//  IRFetchedResultsController.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/10/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface NSFetchedResultsController (IRAdditions)

- (NSManagedObject *) irManagedObjectForURI:(NSURL *)anURI;

@end

@interface IRFetchedResultsController : NSFetchedResultsController {
    
}

@end
