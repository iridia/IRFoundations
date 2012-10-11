//
//  MKMapView+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 4/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (IRAdditions)

- (void) setRegion:(MKCoordinateRegion)region animated:(BOOL)animated completion:(void(^)(void))callback;

- (void) setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated completion:(void(^)(void))callback;

- (void) setVisibleMapRect:(MKMapRect)mapRect animated:(BOOL)animate completion:(void(^)(void))callback;

- (void) setVisibleMapRect:(MKMapRect)mapRect edgePadding:(UIEdgeInsets)insets animated:(BOOL)animate completion:(void(^)(void))callback;

@end
