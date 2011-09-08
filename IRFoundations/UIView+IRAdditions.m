//
//  UIView+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 8/3/11.
//  Copyright 2011 Waveface. All rights reserved.
//

#import "UIView+IRAdditions.h"

@implementation UIView (WAAdditions)

- (UIView *) irFirstResponderInView {

	if (self.isFirstResponder)
		return self;
	
	for (UIView *aSubview in self.subviews) {
		UIView *foundFirstResponder = [aSubview performSelector:_cmd];
		if (foundFirstResponder)
			return foundFirstResponder;
	}
	
	return nil;

}

@end
