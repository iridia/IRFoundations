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

@property (nonatomic, readwrite, copy) void(^onDrawRect) (CGRect rect, CGContextRef context);

@end
