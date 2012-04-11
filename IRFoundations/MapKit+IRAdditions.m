//
//  MapKit+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/10/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MapKit+IRAdditions.h"
#import "UIKit+IRAdditions.h"

NSBundle * IRMapKitBundle (void) {

	static NSBundle *bundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	
		NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"MapKit+IRAdditions" ofType:@"bundle"];
		bundle = [NSBundle bundleWithPath:bundlePath];
		[bundle load];
		
	});
	
	return bundle;

}

UIImage * IRMapKitImage (NSString *name) {

	UIImage *returnedImage = [UIImage irImageNamed:name inBundle:IRMapKitBundle()];
	NSCParameterAssert(returnedImage);
	
	return returnedImage;
	
}

BOOL IRMKCoordinateRegionEqualToRegion (MKCoordinateRegion lhs, MKCoordinateRegion rhs) {

	if (lhs.center.latitude == rhs.center.latitude)
	if (lhs.center.longitude == rhs.center.longitude)
	if (lhs.span.latitudeDelta == rhs.span.latitudeDelta)
	if (lhs.span.longitudeDelta == rhs.span.longitudeDelta)
		return YES;
	
	return NO;

}
