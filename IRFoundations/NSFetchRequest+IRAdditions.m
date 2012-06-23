//
//  NSFetchRequest+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 4/20/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSFetchRequest+IRAdditions.h"
#import <objc/runtime.h>

static NSString * const kDisplayTitle = @"-[NSFetchRequest(IRAdditions) displayTitle]";

@implementation NSFetchRequest (IRAdditions)

- (NSString *) displayTitle {

	return objc_getAssociatedObject(self, &kDisplayTitle);

}

- (void) setDisplayTitle:(NSString *)displayTitle {

	objc_setAssociatedObject(self, &kDisplayTitle, displayTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);

}

@end
