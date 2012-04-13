//
//  NSSet+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef id (^IRSetMapCallback) (id obj, BOOL *stop);


@interface NSSet (IRAdditions)

- (NSSet *) irMap:(IRSetMapCallback)block;

- (NSSet *) irSetByRemovingObjectsInSet:(NSSet *)subtractedSet;

@end
