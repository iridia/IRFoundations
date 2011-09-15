//
//  IRLabel.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/14/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>


extern NSString * const kIRTextLinkAttribute;
extern NSString * const kIRTextActiveBackgroundColorAttribute;

@interface IRLabel : UILabel

@property (nonatomic, readwrite, copy) NSAttributedString *attributedText;

+ (IRLabel *) labelWithFont:(UIFont *)aFont color:(UIColor *)aColor;

- (NSAttributedString *) attributedStringForString:(NSString *)aString;

@end
