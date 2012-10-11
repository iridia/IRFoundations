//
//  MapKit+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/10/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "IRUserTrackingBarButtonItem.h"
#import "MKMapView+IRAdditions.h"

extern NSBundle * IRMapKitBundle (void);
extern UIImage * IRMapKitImage (NSString *name);

extern BOOL IRMKCoordinateRegionEqualToRegion (MKCoordinateRegion lhs, MKCoordinateRegion rhs);
