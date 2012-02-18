//
//  UIScrollView+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/10/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (IRAdditions)

@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, readonly) UIPinchGestureRecognizer *pinchGestureRecognizer;

- (UIPanGestureRecognizer *) irPanGestureRecognizer;
- (UIPinchGestureRecognizer *) irPinchGestureRecognizer;

@end
