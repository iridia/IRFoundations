//
//  IRTintedBarButtonItem.h
//  BarButtonItemWithImageAndTitleTest
//
//  Created by Evadne Wu on 2/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

//	This guy will take your color and pimp your toolbar!

@interface IRTintedBarButtonItem : UIBarButtonItem

+ (UIImage *) contentImageWithImage:(UIImage *)glyph title:(NSString *)title font:(UIFont *)font textColor:(UIColor *)color spacing:(CGFloat)glyphSpacing;

+ (IRTintedBarButtonItem *) itemWithImage:(UIImage *)image title:(NSString *)title block:(void(^)(void))block;

@property (nonatomic, readwrite, retain) UIColor *tintColor;
@property (nonatomic, retain) UISegmentedControl *customView;
@property (nonatomic, readwrite, assign) BOOL flashesMomentarily;
@property (nonatomic, readwrite, copy) void (^block)();

- (void) irHandleSegmentedControlValueChanged:(id)sender;

@end
