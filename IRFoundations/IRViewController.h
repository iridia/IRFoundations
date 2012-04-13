//
//  IRViewController.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/10/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IRViewController : UIViewController

@property (nonatomic, readwrite, copy) BOOL (^onShouldAutorotateToInterfaceOrientation)(UIInterfaceOrientation toOrientation);
@property (nonatomic, readwrite, copy) void (^onLoadView)(void);
@property (nonatomic, readwrite, copy) void (^onViewWillAppear)(void);
@property (nonatomic, readwrite, copy) void (^onViewDidAppear)(void);
@property (nonatomic, readwrite, copy) void (^onViewWillDisappear)(void);
@property (nonatomic, readwrite, copy) void (^onViewDidDisappear)(void);

@end
