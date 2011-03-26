//
//  IRBarButtonItem.m
//  IRFoundations
//
//  Created by Evadne Wu on 3/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRBarButtonItem.h"


@implementation IRBarButtonItem

+ (id) itemWithCustomView:(UIView *)aView {

	return [[[self alloc] initWithCustomView:aView] autorelease];

}

@end
