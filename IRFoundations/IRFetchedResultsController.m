//
//  IRFetchedResultsController.m
//  Milk
//
//  Created by Evadne Wu on 3/10/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRFetchedResultsController.h"
#import "IRManagedObjectContext.h"

@implementation NSFetchedResultsController (IRAdditions)

- (NSManagedObject *) irManagedObjectForURI:(NSURL *)anURI {

	return [self.managedObjectContext irManagedObjectForURI:anURI];

}

@end

@implementation IRFetchedResultsController

@end
