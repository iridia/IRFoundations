//
//  IRViewController.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/10/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IRViewController : UIViewController

@property (nonatomic, readwrite, copy) BOOL (^onShouldAutorotateToInterfaceOrientation)(IRViewController *self, UIInterfaceOrientation toOrientation);
@property (nonatomic, readwrite, copy) void (^onLoadview)(IRViewController *self);
@property (nonatomic, readwrite, copy) void (^onViewWillAppear)(IRViewController *self);
@property (nonatomic, readwrite, copy) void (^onViewDidAppear)(IRViewController *self);
@property (nonatomic, readwrite, copy) void (^onViewWillDisappear)(IRViewController *self);
@property (nonatomic, readwrite, copy) void (^onViewDidDisappear)(IRViewController *self);

@end
