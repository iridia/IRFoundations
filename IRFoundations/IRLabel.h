//
//  IRLabel.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/14/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


extern NSString * const kIRTextLinkAttribute;
extern NSString * const kIRTextActiveBackgroundColorAttribute;

@interface IRLabel : UILabel

@property (nonatomic, readwrite, copy) NSAttributedString *attributedText;
@property (nonatomic, readwrite, assign) CGFloat trailingWhitespaceWidth;	//	Default is 0; if any, leaves a block of whitespace at the last line and attempts to truncate if appropriate
@property (nonatomic, readonly, assign) BOOL lastDrawnRectRequiredTailTruncation;

+ (IRLabel *) labelWithFont:(UIFont *)aFont color:(UIColor *)aColor;

- (NSAttributedString *) attributedStringForString:(NSString *)aString;
- (NSAttributedString *) attributedStringForString:(NSString *)aString font:(UIFont *)aFont color:(UIColor *)aColor;

@end





@interface UILabel (IRAdditions)

- (void) irPlaceBehindLabel:(UILabel *)anotherLabel; // UIEdgeInsetsZero
- (void) irPlaceBehindLabel:(UILabel *)anotherLabel withEdgeInsets:(UIEdgeInsets)edgeInsets;

@end
