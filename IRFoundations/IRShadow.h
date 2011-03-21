//
//  IRShadow.h
//  Milk
//
//  Created by Evadne Wu on 1/29/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IRShadow : NSObject <NSCoding>

@property (nonatomic, readwrite, retain) UIColor *color;
@property (nonatomic, readwrite, assign) CGSize offset;
@property (nonatomic, readwrite, assign) CGFloat spread;
@property (nonatomic, readwrite, assign) UIEdgeInsets edgeInsets;

+ (IRShadow *) shadowWithColor:(UIColor *)color offset:(CGSize)offset spread:(CGFloat)spread;
+ (IRShadow *) shadowWithColor:(UIColor *)color offset:(CGSize)offset spread:(CGFloat)spread edgeInsets:(UIEdgeInsets)edgeInsets;

@end
