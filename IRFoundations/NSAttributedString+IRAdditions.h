//
//  NSAttributedString+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/11/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface NSAttributedString (IRAdditions)

+ (NSDictionary *) irAttributesForFont:(UIFont *)aFont color:(UIColor *)aColor;

+ (NSAttributedString *) irAttributedStringWithString:(NSString *)baseString attributes:(NSDictionary *)attributesOrNil;

- (NSAttributedString *) irAttributedStringByReplacingMatchesOfRegularExpression:(NSRegularExpression *)anExpression withOptions:(NSRegularExpressionOptions)options range:(NSRange)aRange usingBlock:(NSAttributedString * (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))aBlock;

- (NSAttributedString *) irAttributedStringByReplacingMatchesOfRegularExpression:(NSRegularExpression *)anExpression withOptions:(NSRegularExpressionOptions)options range:(NSRange)aRange usingMarkedTextRange:(NSRange *)markedTextRangeOrNull block:(NSAttributedString * (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))aBlock;

//	The latter will attempt to keep track of marked text when replacing string occurrances, if markedTextRangeOrNull is not NULL.  The former calls the latter with a NULL range.

- (NSAttributedString *) irAttributedStringByReplacingStringsWithEnumeratedAttributesInRange:(NSRange)aRange withOptions:(NSAttributedStringEnumerationOptions)options usingBlock:(NSAttributedString * (^)(NSDictionary *attrs, NSRange range, BOOL *stop))aBlock;

- (NSRange) irFullRange;

@end


@interface UIFont (NSAttributedString_IRAdditions)

- (CTParagraphStyleRef) irFixedLineHeightParagraphStyle;

@end
