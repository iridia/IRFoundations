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
	
	CGPoint *lineOrigins = malloc(sizeof(CGPoint) * lineCount);
	CTFrameGetLineOrigins(aFrame, (CFRange) { 0, lineCount }, lineOrigins);
	
	[((__bridge NSArray *)lines) enumerateObjectsUsingBlock: ^ (id aLine, NSUInteger idx, BOOL *stop) {
		aBlock((__bridge CTLineRef)aLine, lineOrigins[idx], stop);
	}];
	
	free(lineOrigins);

}


void irCTLineEnumerateRuns(CTLineRef aLine, void(^aBlock)(CTRunRef aRun, double runWidth, BOOL *stop)) {

	if (!aLine)
		return;

	CFArrayRef runs = CTLineGetGlyphRuns(aLine);
	if (!runs)
		return;
	
	[(__bridge NSArray *)runs enumerateObjectsUsingBlock: ^ (id aRun, NSUInteger idx, BOOL *stop) {
		aBlock((__bridge CTRunRef)aRun, CTRunGetTypographicBounds((__bridge CTRunRef)aRun, (CFRange){ 0, 0 }, NULL, NULL, NULL), stop);
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
			
			if (![(__bridge NSDictionary *)CTRunGetAttributes(aRun) irPassesTestSuite:testSuite])
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





NSArray * irCTFrameFindNeighborRuns (CTFrameRef aFrame, CTRunRef referencedRun, NSDictionary *testSuite) {

	if (![(__bridge NSDictionary *)CTRunGetAttributes(referencedRun) irPassesTestSuite:testSuite])
		return [NSArray array];

	NSMutableArray *returnedArray = [NSMutableArray array];
	__block BOOL hasSeenReferencedRun = NO;
	
	irCTFrameEnumerateLines(aFrame,  ^ (CTLineRef aLine, CGPoint lineOrigin, BOOL *stopLineEnum) {
	
		irCTLineEnumerateRuns(aLine, ^ (CTRunRef aRun, double runWidth, BOOL *stopRunEnum) {
		
			//	If the run is valid just queue it
			if ([(__bridge NSDictionary *)CTRunGetAttributes(aRun) irPassesTestSuite:testSuite]) {
				[returnedArray addObject:(__bridge id)aRun];
				hasSeenReferencedRun = hasSeenReferencedRun ? hasSeenReferencedRun : (aRun == referencedRun);
				return;
			}
			
			//	If an invalid run came in after we’ve seen the referenced run, it’s time to end enumeration early
			if (hasSeenReferencedRun) {
				*stopLineEnum = YES;
				*stopRunEnum = YES;
				return;
			}
			
			//	There is possibility that we just pushed a lot of valid but irrelevant runs
			//	Remove them all, just to be safe				
			[returnedArray removeAllObjects];
			
		});
		
	});
		
	return returnedArray;	

}





UIBezierPath * irCTFrameGetRunOutline (CTFrameRef aFrame, NSArray *runs, UIEdgeInsets edgeInsets, CGFloat radius, BOOL averageMetrics, BOOL appendsIntegralRects, BOOL shiftsAppendedRectsToCompensateLeading) {

	UIBezierPath *returnedPath = [UIBezierPath bezierPath];
	
	if (![runs count])
		return returnedPath;
	
	NSSet *queriedRuns = [NSSet setWithArray:runs];	
	
	irCTFrameEnumerateLines(aFrame, ^(CTLineRef aLine, CGPoint lineOrigin, BOOL *stopLineEnum) {
		
		CGFloat lineAscent, lineDescent, lineLeading;
		CTLineGetTypographicBounds(aLine, &lineAscent, &lineDescent, &lineLeading);
		
		//	lineOrigin = (CGPoint){ lineOrigin.x, lineOrigin.y * -1 + OUITextLayoutUnlimitedSize + lineAscent + lineDescent };

		__block CGFloat usedWidth = 0;
		__block UIBezierPath *pathsInLine = [UIBezierPath bezierPath];
		
		irCTLineEnumerateRuns(aLine, ^(CTRunRef aRun, double runWidth, BOOL *stopRunEnum) {
			
			if ([queriedRuns containsObject:(__bridge id)aRun]) {
			
				CGFloat runAscent, runDescent, runLeading;
				CTRunGetTypographicBounds(aRun, (CFRange){0, 0}, &runAscent, &runDescent, &runLeading);
				
				CGRect appendedRect = UIEdgeInsetsInsetRect((CGRect) {
				
					lineOrigin.x + usedWidth,
					lineOrigin.y + (shiftsAppendedRectsToCompensateLeading ? (runLeading * -0.5) : 0) - runDescent,
					runWidth,
					runAscent + runDescent + runLeading
				
				}, edgeInsets);
				
				if (appendsIntegralRects)
				appendedRect = CGRectIntegral(appendedRect);
				
				if ((radius == 0) || averageMetrics) {
				
					[pathsInLine appendPath:[UIBezierPath bezierPathWithRect:appendedRect]];
				
				} else {
				
					[pathsInLine appendPath:[UIBezierPath bezierPathWithRoundedRect:appendedRect cornerRadius:radius]];					
				
				}
			
			}
			
			usedWidth += runWidth;		
					
		});
		
		if (!pathsInLine || pathsInLine.empty)
			return;

		[returnedPath appendPath:(averageMetrics ? (
		
			(radius == 0) ? [UIBezierPath bezierPathWithRect:[pathsInLine bounds]] : [UIBezierPath bezierPathWithRoundedRect:[pathsInLine bounds] cornerRadius:radius]
			
		) : (
		
			pathsInLine
			
		))];
	
	});
	
	return returnedPath;
	
}
