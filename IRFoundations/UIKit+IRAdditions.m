//
//  UIKit+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/7/12.
//  Copyright 2012 Iridia Productions. All rights reserved.
//

#import "UIKit+IRAdditions.h"

NSBundle * IRUIKitBundle (void) {

	static NSBundle *bundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	
		NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"UIKit+IRAdditions" ofType:@"bundle"];
	
		bundle = [[NSBundle bundleWithPath:bundlePath] retain];
		[bundle load];
		
	});
	
	return bundle;

}

UIImage * IRUIKitImage (NSString *name) {

	UIImage *returnedImage = [UIImage irImageNamed:name inBundle:IRUIKitBundle()];
	NSCParameterAssert(returnedImage);
	
	return returnedImage;
	
}
