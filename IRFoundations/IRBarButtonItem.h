//
//  IRBarButtonItem.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRShadow.h"
#import "IRBorder.h"

enum {
	
	IRBarButtonItemStyleBordered = 1,
	IRBarButtonItemStyleBack = 2,

	IRBarButtonItemStyleBorderedLandscapePhone = 3,
	IRBarButtonItemStyleBackLandscapePhone = 4

}; typedef NSUInteger IRBarButtonItemStyle;

@interface IRBarButtonItem : UIBarButtonItem

+ (id) itemWithCustomView:(UIView *)aView;

+ (id) itemWithTitle:(NSString *)aTitle action:(void(^)(void))aBlock;

+ (id) itemWithButton:(UIButton *)aButton wiredAction:(void(^)(UIButton *senderButton, IRBarButtonItem *senderItem))aBlock;
- (IBAction) handleCustomButtonAction:(id)sender; // button will be wired to the item, which runs the block

+ (id) itemWithCustomImage:(UIImage *)aFullImage highlightedImage:(UIImage *)aHighlightedImage;
//	Hosted transparent button

+ (id) itemWithCustomImage:(UIImage *)aFullImage landscapePhoneImage:(UIImage *)landscapePhoneImage highlightedImage:(UIImage *)aHighlightedImage highlightedLandscapePhoneImage:(UIImage *)highlightedLandscapePhoneImage;

+ (id) itemWithSystemItem:(UIBarButtonSystemItem)aSystemItem wiredAction:(void(^)(IRBarButtonItem *senderItem))aBlock;

+ (UIImage *) backButtonImageWithTitle:(NSString *)aTitle font:(UIFont *)fontOrNil backgroundColor:(UIColor *)backgroundColorOrNil gradientColors:(NSArray *)backgroundGradientColorsOrNil innerShadow:(IRShadow *)innerShadowOrNil border:(IRBorder *)borderOrNil shadow:(IRShadow *)shadowOrNil;

+ (UIImage *) buttonImageForStyle:(IRBarButtonItemStyle)aStyle withTitle:(NSString *)aTitle font:(UIFont *)fontOrNil backgroundColor:(UIColor *)backgroundColorOrNil gradientColors:(NSArray *)backgroundGradientColorsOrNil innerShadow:(IRShadow *)innerShadowOrNil border:(IRBorder *)borderOrNil shadow:(IRShadow *)shadowOrNil;

+ (UIImage *) buttonImageForStyle:(IRBarButtonItemStyle)aStyle withTitle:(NSString *)aTitle font:(UIFont *)fontOrNil color:(UIColor *)titleColor shadow:(IRShadow *)titleShadow backgroundColor:(UIColor *)backgroundColorOrNil gradientColors:(NSArray *)backgroundGradientColorsOrNil innerShadow:(IRShadow *)innerShadowOrNil border:(IRBorder *)borderOrNil shadow:(IRShadow *)shadowOrNil;

+ (id) backItemWithTitle:(NSString *)aTitle tintColor:(UIColor *)aColor; // actually *drawn* image
+ (id) itemWithTitle:(NSString *)aTitle tintColor:(UIColor *)aColor; // actually *drawn* image

@property (nonatomic, readwrite, copy) void (^block)();

@end
