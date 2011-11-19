//
//  UIViewController+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 11/18/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "UIViewController+IRAdditions.h"

@implementation UIViewController (IRAdditions)

- (UIViewController *) irModalHostingViewController {

	if ([self respondsToSelector:@selector(presentingViewController)])
		return (UIViewController *)[self performSelector:@selector(presentingViewController)];
	
	return (UIViewController *)[self parentViewController];

}

@end
