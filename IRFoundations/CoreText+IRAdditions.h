//
//  CoreText+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 9/12/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import "Foundation+IRAdditions.h"
#import "NSAttributedString+IRAdditions.h"

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

#ifndef __CoreText_IRAdditions__
#define __CoreText_IRAdditions__

extern void irCTFrameEnumerateLines(CTFrameRef aFrame, void (^aBlock)(CTLineRef aLine, CGPoint lineOrigin, BOOL *stop));
extern void irCTLineEnumerateRuns(CTLineRef aLine, void(^aBlock)(CTRunRef aRun, double runWidth, BOOL *stop));

extern CTParagraphStyleRef irCTParagraphStyleCreateWithFixedLines(CGFloat lineheight, CGFloat lineSpacing);

extern CTRunRef irCTFrameFindRunAtPoint (CTFrameRef aFrame, CGPoint aPoint, CGFloat searchTolerance, CFDictionaryRef *usedRunAttributes, NSDictionary *testSuite);
//	The suite is a dictionary containing keys to IRDictionaryPairTest blocks
//	If nil, there will be no testing, otherwise only runs whose attributes conform to the test suite would be returned

#endif
