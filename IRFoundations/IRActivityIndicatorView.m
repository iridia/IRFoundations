//
//  IRActivityIndicatorView.m
//  Milk
//
//  Created by Evadne Wu on 1/24/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRActivityIndicatorView.h"


@implementation IRActivityIndicatorView

@synthesize animating;

- (void) setAnimating:(BOOL)inFlag {

	if (inFlag) {
	
		[self startAnimating];
		
	} else {
	
		[self stopAnimating];
	
	}

}

@end
