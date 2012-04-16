//
//  IRStoryboard.m
//  IRFoundations
//
//  Created by Evadne Wu on 4/16/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRStoryboard.h"

#import <objc/runtime.h>


NSString * const kStoryboardID = @"-[UIViewController(IRStoryboardAdditionsPrivate) storyboardIdentifier]";


@interface UIViewController (IRStoryboardAdditionsPrivate)

@property (nonatomic, readwrite, copy) NSString *storyboardIdentifier;

@end


@implementation IRStoryboard

- (id) instantiateViewControllerWithIdentifier:(NSString *)identifier {

	id answer = [super instantiateViewControllerWithIdentifier:identifier];
	
	if ([answer isKindOfClass:[UIViewController class]])
		((UIViewController *)answer).storyboardIdentifier = identifier;
	
	return answer;

}

@end


@implementation UIViewController (IRStoryboardAdditionsPrivate)

- (NSString *) storyboardIdentifier {

	return objc_getAssociatedObject(self, &kStoryboardID);

}

- (void) setStoryboardIdentifier:(NSString *)newStoryboardIdentifier {

	objc_setAssociatedObject(self, &kStoryboardID, newStoryboardIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);

}

@end
