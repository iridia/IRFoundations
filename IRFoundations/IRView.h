//
//  IRView.h
//  IRFoundations
//
//  Created by Evadne Wu on 1/6/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>



@interface IRView : UIView

@property (nonatomic, readwrite, copy) UIView * (^onHitTestWithEvent)(CGPoint aPoint, UIEvent *anEvent, UIView *superAnswer);
@property (nonatomic, readwrite, copy) BOOL (^onPointInsideWithEvent)(CGPoint aPoint, UIEvent *anEvent, BOOL superAnswer);
@property (nonatomic, readwrite, copy) void (^onLayoutSubviews)();
@property (nonatomic, readwrite, copy) CGSize (^onSizeThatFits)(CGSize proposedSize, CGSize superAnswer);
@property (nonatomic, readwrite, copy) void(^onDrawRect) (CGRect rect, CGContextRef context);

@end
