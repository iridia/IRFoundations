//
//  CoreText+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 9/12/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "CoreText+IRAdditions.h"

void irCTFrameEnumerateLines(CTFrameRef aFrame, void (^aBlock)(CTLineRef aLine, CGPoint lineOrigin, BOOL *stop)) {

	if (!aFrame)
		return;
	
	CFArrayRef lines = CTFrameGetLines(aFrame);
	if (!lines)
		return;
	
	CFIndex lineCount = CFArrayGetCount(lines);
	if (!lineCount)
		return;
	
	CGPoint *lineOrigins = malloc(sizeof(*lineOrigins) * lineCount);
	CTFrameGetLineOrigins(aFrame, (CFRange) { 0, lineCount }, lineOrigins);
	
	[((NSArray *)lines) enumerateObjectsUsingBlock: ^ (id aLine, NSUInteger idx, BOOL *stop) {
		aBlock((CTLineRef)aLine, lineOrigins[idx], stop);
	}];
	
	free(lineOrigins);

}


void irCTLineEnumerateRuns(CTLineRef aLine, void(^aBlock)(CTRunRef aRun, double runWidth, BOOL *stop)) {

	if (!aLine)
		return;

	CFArrayRef runs = CTLineGetGlyphRuns(aLine);
	if (!runs)
		return;
	
	[(NSArray *)runs enumerateObjectsUsingBlock: ^ (id aRun, NSUInteger idx, BOOL *stop) {
		aBlock((CTRunRef)aRun, CTRunGetTypographicBounds((CTRunRef)aRun, (CFRange){ 0, 0 }, NULL, NULL, NULL), stop);
	}];

}


CTParagraphStyleRef irCTParagraphStyleCreateWithFixedLines(CGFloat lineheight, CGFloat lineSpacing) {
	
	const CGFloat decoyLineHeight = 1.0;
	const CGFloat pad = 1.0;	//	https://github.com/omnigroup/omnigroup/issues/issue/12
	CGFloat realLineHeight = lineheight - decoyLineHeight;	// Compensate
	CGFloat realLineSpacing = realLineHeight;	// FIXME: Respect inLineSpacing;
	
	CTParagraphStyleSetting paragraphStyleSettings[] = {
		{ kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(decoyLineHeight), &decoyLineHeight },
		{ kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(decoyLineHeight), &decoyLineHeight },	
		{ kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(pad), &pad },
#ifdef __IPHONE_4_3
		{ kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(realLineSpacing), &realLineSpacing },
		{ kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(realLineSpacing), &realLineSpacing },
		{ kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(realLineSpacing), &realLineSpacing },		
#else
		{ kCTParagraphStyleSpecifierLineSpacing, sizeof(realLineSpacing), &realLineSpacing },
#endif		
	};

	return CTParagraphStyleCreate(paragraphStyleSettings, sizeof(paragraphStyleSettings) / sizeof(CTParagraphStyleSetting));

}


CTRunRef irCTFrameFindRunAtPoint (CTFrameRef aFrame, CGPoint aPoint, CGFloat searchTolerance, CFDictionaryRef *usedRunAttributes, NSDictionary *testSuite) {

	//	The tolerance is at least 16 for practical use — there is absolutely no way to overlap a zero rect
	//	And a smaller tolerance simply won’t work for touch interfaces.
	//	The more area the tolerable rect overlaps a certain run, the more likely the run is the preferred one
	
	CTRunRef introspectedRun = NULL;
	CGFloat realTolerance = MAX(16, searchTolerance);
	CGRect tolerableRect = (CGRect) {
		(CGPoint) { aPoint.x - realTolerance * 0.5, aPoint.y - realTolerance * 0.5 }, 
		(CGSize) { realTolerance, realTolerance }
	};
	
	__block CTRunRef bestMatchingRun = NULL;
	__block CGFloat bestMatchingRunScore = 0;
	
	irCTFrameEnumerateLines(aFrame, ^ (CTLineRef aLine, CGPoint lineOrigin, BOOL *stop) {
		
		CGFloat lineAscent, lineDescent, lineLeading;
		CTLineGetTypographicBounds(aLine, &lineAscent, &lineDescent, &lineLeading);
		
		CGFloat minY = lineOrigin.y - lineDescent;
		CGFloat maxY = lineOrigin.y + lineAscent;
		
		if ((CGRectGetMaxY(tolerableRect) < minY) || (CGRectGetMinY(tolerableRect) > maxY))
			return;

		__block CGFloat usedWidth = 0;
		
		irCTLineEnumerateRuns(aLine, ^(CTRunRef aRun, double runWidth, BOOL *stop) {
			
			usedWidth += runWidth;
			
			if (![(NSDictionary *)CTRunGetAttributes(aRun) irPassesTestSuite:testSuite])
				return;
			
			CGFloat runAscent, runDescent, runLeading;
			CTRunGetTypographicBounds(aRun, (CFRange){0, 0}, &runAscent, &runDescent, &runLeading);
			
			CGRect intersection = CGRectIntersection(tolerableRect, (CGRect) {
				(CGPoint) { lineOrigin.x + usedWidth - runWidth, lineOrigin.y - runAscent },
				(CGSize) { runWidth, runAscent + runDescent + runLeading }
			});	
			
			if (CGRectEqualToRect(intersection, CGRectNull))
				return;
			
			CGFloat score = CGRectGetWidth(intersection) * CGRectGetHeight(intersection);
			
			if (score <= bestMatchingRunScore)
				return;
			
			bestMatchingRun = aRun;
			bestMatchingRunScore = score;
		
		});
	
	});	
	
	introspectedRun = bestMatchingRun;
	
	if (!introspectedRun)
		return NULL;
	
	if (usedRunAttributes != NULL)
		*usedRunAttributes = CTRunGetAttributes(introspectedRun);
	
	return introspectedRun;

}
