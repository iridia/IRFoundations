//
//  IRUserTrackingBarButtonItem.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/10/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKMapView;
@interface IRUserTrackingBarButtonItem : UIBarButtonItem

@property (nonatomic, readwrite, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, readwrite, assign) UIBarStyle barStyle;
@property (nonatomic, readwrite, assign) BOOL translucent;

@end
