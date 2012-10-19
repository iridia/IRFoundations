//
//  NSFetchRequest+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 4/20/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSFetchRequest+IRAdditions.h"
#import <objc/runtime.h>

static void *kDisplayTitle = &kDisplayTitle;
static void *kUserInfo = &kUserInfo;

@implementation NSFetchRequest (IRAdditions)

- (NSString *) displayTitle {

	return objc_getAssociatedObject(self, &kDisplayTitle);

}

- (void) setDisplayTitle:(NSString *)displayTitle {

	objc_setAssociatedObject(self, &kDisplayTitle, displayTitle, OBJC_ASSOCIATION_COPY_NONATOMIC);

}

- (NSDictionary *) userInfo {

	return objc_getAssociatedObject(self, &kUserInfo);

}

- (void) setUserInfo:(NSDictionary *)userInfo {

	objc_setAssociatedObject(self, &kUserInfo, userInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

@end
