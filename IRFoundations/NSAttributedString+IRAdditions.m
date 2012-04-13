//
//  NSAttributedString+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/11/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "NSAttributedString+IRAdditions.h"


@implementation NSAttributedString (IRAdditions)

+ (NSDictionary *) irAttributesForFont:(UIFont *)aFont color:(UIColor *)aColor {

	if (!aFont || !aColor)
		return nil;

	CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)(aFont.fontName), aFont.pointSize, NULL);
	
	NSMutableDictionary *returnedDictionary = [NSMutableDictionary dictionary];
	[returnedDictionary setObject:(__bridge id)fontRef forKey:(NSString *)kCTFontAttributeName];
	if (aColor)
		[returnedDictionary setObject:(id)aColor.CGColor forKey:(NSString *)kCTForegroundColorAttributeName];

	CFRelease(fontRef);
	return returnedDictionary;

}

+ (NSAttributedString *) irAttributedStringWithString:(NSString *)baseString attributes:(NSDictionary *)attributesOrNil {

	return [[NSAttributedString alloc] initWithString:baseString attributes:attributesOrNil];

}

- (NSAttributedString *) irAttributedStringByReplacingMatchesOfRegularExpression:(NSRegularExpression *)anExpression withOptions:(NSRegularExpressionOptions)options range:(NSRange)aRange usingBlock:(NSAttributedString * (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))aBlock {

	return [self irAttributedStringByReplacingMatchesOfRegularExpression:anExpression withOptions:options range:aRange usingMarkedTextRange:&(NSRange){0, 0} block:aBlock];

}

- (NSAttributedString *) irAttributedStringByReplacingMatchesOfRegularExpression:(NSRegularExpression *)anExpression withOptions:(NSRegularExpressionOptions)options range:(NSRange)aRange usingMarkedTextRange:(NSRange *)markedTextRangeOrNull block:(NSAttributedString * (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))aBlock {

	__block int rangeOffset = 0;
	
	NSMutableAttributedString *returnedString = [self mutableCopy];
	
	[anExpression enumerateMatchesInString:[[self string] copy] options:options range:NSMakeRange(0, [[returnedString string] length]) usingBlock: ^ (NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
	
		NSAttributedString *replacementString = aBlock(result, flags, stop);
		
		NSRange normalizedRange = result.range;
		normalizedRange.location -= rangeOffset;
	
	//	Duh.  This never could be unsigned, the delta could be negative.
		NSInteger rangeOffsetDelta = result.range.length - [replacementString length];
		rangeOffset += rangeOffsetDelta;
		
		[returnedString replaceCharactersInRange:normalizedRange withAttributedString:replacementString];
		
		if (markedTextRangeOrNull != NULL) {
		
			if (NSIntersectionRange(normalizedRange, *markedTextRangeOrNull).length != 0)
			[NSException raise:NSInternalInconsistencyException format:@"Mutated range of marked text (%@) should never intersect the range of substring being replaced (%@).",
			
				NSStringFromRange(*markedTextRangeOrNull),
				NSStringFromRange(normalizedRange)
			
			];
			
			BOOL currentRangeIsAfterMarkedText = (NSMaxRange(normalizedRange) >= (*markedTextRangeOrNull).location); 
			
			if (currentRangeIsAfterMarkedText)
			(*markedTextRangeOrNull).location -= rangeOffsetDelta;
			
		}
		
	}];

	return returnedString;

}

- (NSAttributedString *) irAttributedStringByReplacingStringsWithEnumeratedAttributesInRange:(NSRange)aRange withOptions:(NSAttributedStringEnumerationOptions)options usingBlock:(NSAttributedString * (^)(NSDictionary *attrs, NSRange range, BOOL *stop))aBlock {

	__block int rangeOffset = 0;
	
	NSMutableAttributedString *returnedString = [self mutableCopy];
	
	[self enumerateAttributesInRange:aRange options:options usingBlock: ^ (NSDictionary *attrs, NSRange range, BOOL *stop) {
	
		BOOL shallStop = NO;
	
		NSAttributedString *replacementString = aBlock(attrs, range, &shallStop);
				
		*stop = shallStop;
		
		if (!replacementString) {
		
			return;
			
		}
		
		NSRange normalizedRange = range;
		normalizedRange.location -= rangeOffset;
		
		[returnedString deleteCharactersInRange:normalizedRange];
		[returnedString insertAttributedString:replacementString atIndex:normalizedRange.location];
		
		rangeOffset += normalizedRange.length - [replacementString length];
	
	}];
		
	return returnedString;

}

- (NSRange) irFullRange {

	return NSMakeRange(0, [[self string] length]);

}

@end


@implementation UIFont (NSAttributedString_IRAdditions)

- (CTParagraphStyleRef) irFixedLineHeightParagraphStyle {

	return [[self class] irFixedLineHeightParagraphStyleForHeight:self.leading];

}

+ (CTParagraphStyleRef) irFixedLineHeightParagraphStyleForHeight:(float_t)lineHeight {

	CTParagraphStyleSetting paragraphStyles[] = (CTParagraphStyleSetting[]){
		(CTParagraphStyleSetting){ kCTParagraphStyleSpecifierLineHeightMultiple, sizeof(float_t), (float_t[]){ 0.01f } },
		(CTParagraphStyleSetting){ kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(float_t), (float_t[]){ lineHeight } },
		(CTParagraphStyleSetting){ kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(float_t), (float_t[]){ lineHeight } },
		(CTParagraphStyleSetting){ kCTParagraphStyleSpecifierLineSpacing, sizeof(float_t), (float_t[]){ 0.0f } },
		(CTParagraphStyleSetting){ kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(float_t), (float_t[]){ 0.0f } },
		(CTParagraphStyleSetting){ kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(float_t), (float_t[]){ 0.0f } }
	};

	CTParagraphStyleRef paragraphStyleRef = CTParagraphStyleCreate(paragraphStyles, sizeof(paragraphStyles) / sizeof(CTParagraphStyleSetting));
	
	return paragraphStyleRef;

}

@end
