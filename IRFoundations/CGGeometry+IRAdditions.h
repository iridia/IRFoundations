//
//  CGGeometry+IRAdditions.h
//  Tarotie
//
//  Created by Evadne Wu on 6/1/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TargetConditionals.h"

#import <CoreGraphics/CoreGraphics.h>

#if TARGET_OS_IPHONE
	#import <UIKit/UIKit.h>
#else
	#import <ApplicationServices/ApplicationServices.h>
	#define NSStringFromCGRect(aRect) NSStringFromRect(NSRectFromCGRect(aRect))
	#define NSStringFromCGSize(aSize) NSStringFromSize(NSSizeFromCGSize(aSize))
	#define NSStringFromCGPoint(aPoint) NSStringFromPoint(NSPointFromCGPoint(aPoint))
#endif

#import <QuartzCore/QuartzCore.h>
#import <CoreFoundation/CFDictionary.h>

#ifndef __CGGeometry_IRAdditions_Defines__
#define __CGGeometry_IRAdditions_Defines__

typedef enum { irCenter, irTop, irTopRight, irRight, irBottomRight, irBottom, irBottomLeft, irLeft, irTopLeft } IRAnchor;
typedef enum { irUnflipped = NO, irFlipped = YES } irFlipping;
enum { IRBorderTypeInset = 1, IRBorderTypeNormal = 0, IRBorderTypeOutset = -1 }; typedef NSUInteger IRBorderType;
typedef CGPoint IRDelta;

enum {
	
	IREdgeNone = 0,
	IREdgeTop = 1 << 0,
	IREdgeBottom = 1 << 1,	
	IREdgeLeft = 1 << 2,
	IREdgeRight = 1 << 3,
	
	IREdgeHorizontal = (IREdgeTop | IREdgeBottom),
	IREdgeVertical = (IREdgeLeft | IREdgeRight),

}; typedef NSUInteger IREdge;

#if 0

struct IRLine {

	CGPoint origin;
	CGPoint destination;
	CGFloat width;
	UIColor *color;

}; typedef struct IRLine IRLine;


struct IRBorder {
	
	IREdge edge;
	IRBorderType type;
	CGFloat width;
	UIColor *color;

}; typedef struct IRBorder IRBorder;


struct IRShadow {

	IREdge edge;
	CGPoint offset;
	CGFloat spread;
	UIColor *color;
	
}; typedef struct IRShadow IRShadow;


extern IRLine IRLineMake(CGPoint origin, CGPoint destination, CGFloat width, UIColor *color);
extern IRBorder IRBorderMake (IREdge edge, IRBorderType type, CGFloat width, UIColor *color);
extern IRShadow IRShadowMake(IREdge edge, CGPoint offset, CGFloat spread, UIColor *color);

#endif

#endif





#ifndef __CGGeometry_IRAdditions__
#define __CGGeometry_IRAdditions__

extern BOOL irCGPointIsAbovePoint (CGPoint aPoint, CGPoint referencedPoint, BOOL flipped);

extern CGRect IRCGSizeGetCenteredInRect(CGSize enclosedSize, CGRect enclosingRect, CGFloat minimalPadding, BOOL flipped);

extern CGPoint irCGRectGetCenterOfRectBounds (CGRect aRect);
extern CGPoint irCGRectGetCenterOfRectFrame (CGRect aRect);

extern IRDelta IRDeltaMake (CGFloat deltaX, CGFloat deltaY);
extern IRDelta IRDeltaFromSize (CGSize aSize);
extern IRDelta IRDeltaFromPoints (CGPoint fromPoint, CGPoint toPoint);
extern IRDelta IRDeltaFromRectSizes(CGRect fromRect, CGRect toRect);

extern IRAnchor IRAnchorForEdge (IREdge edge);

extern CGRect irCGRectApplyDelta (CGRect aRect, IRDelta aDelta);
extern CGRect irCGRectApplySizeDelta (CGRect aRect, IRDelta aDelta);
extern CGRect irCGRectApplyOrigin (CGRect aRect, CGPoint anOrigin);
extern CGPoint irCGRectAnchor (CGRect aRect, IRAnchor anchor, BOOL flipped);
extern CGPoint irUnitPointForAnchor (IRAnchor anchor, BOOL flipped);
extern CGRect IRCGRectAlignToRect (CGRect theRect, CGRect referenceRect, IRAnchor anchor, BOOL flipped);

extern CGRect irAnchoredRectFromEdge (CGRect aRect, IREdge anEdge, CGFloat widthOrHeight);

extern CGFloat irDistanceFromRectToPoint (CGRect aRect, CGPoint aPoint, IRAnchor anchor);

extern CGRect IRUnitRectWithRectAndEdgeInsets (CGRect aRect, UIEdgeInsets edgeInsets);

extern CGPoint irCGPointAddPoint(CGPoint aPoint, CGPoint anotherPoint);

#define irDump(inCGExpression) (( ^ { __typeof__(inCGExpression) aCGStruct = inCGExpression; NSLog(@"%@ %s", irDumpImpl(@encode(__typeof__(inCGExpression)), (void *)&aCGStruct), #inCGExpression ); })())

#define irDumpLog(inCGExpression,...) (( ^ { __typeof__(inCGExpression) aCGStruct = inCGExpression; NSLog(@"%@: %@", irDumpImpl(@encode(__typeof__(inCGExpression)), (void *)&aCGStruct), [NSString stringWithFormat:__VA_ARGS__]); })())

extern NSString* irDumpImpl (const char *encodedString, void * aPointer);

#endif










#ifndef __CGGeometry_IRAdditions_Compatibility__
#define __CGGeometry_IRAdditions_Compatibility__

#define IRCGEdge IREdge
#define IRCGEdgeNone IREdgeNone
#define IRCGEdgeTop IREdgeTop
#define IRCGEdgeBottom IREdgeBottom
#define IRCGEdgeRight IREdgeRight
#define IRCGEdgeLeft IREdgeLeft
#define IRCGEdgeHorizontal IREdgeHorizontal
#define IRCGEdgeVertical IREdgeVertical

#define IRCGLine IRLine
#define IRCGBorder IRBorder
#define IRCGShadow IRShadow

#define IRCGLineMake IRLineMake
#define IRCGBorderMake IRBorderMake
#define IRCGShadowMake IRShadowMake

#define IRCGBorderType IRBorderType
#define IRCGBorderTypeOutset IRBorderTypeOutset
#define IRCGBorderTypeInset IRBorderTypeInset
#define IRCGBorderTypeNormal IRBorderTypeNormal

#define IRCGTranslateAlignType IRAnchor
#define IRCGTranslateAlignTypeCenter irCenter
#define IRCGTranslateAlignTypeTop irTop
#define IRCGTranslateAlignTypeTopRight irTopRight
#define IRCGTranslateAlignTypeRight irRight
#define IRCGTranslateAlignTypeBottomRight irBottomRight
#define IRCGTranslateAlignTypeBottom irBottom
#define IRCGTranslateAlignTypeBottomLeft irBottomLeft
#define IRCGTranslateAlignTypeLeft irLeft
#define IRCGTranslateAlignTypeTopLeft irTopLeft 

#define IRCGFlippingFlag irFlipping
#define IRCGFlippingFlagFlipped irFlipped
#define IRCGFlippingFlagUnflipped irUnflipped

#define IRCGTranslateAlignTypeFromEdge IRAnchorForEdge

#define IRCGRectAlignToPixelGrid CGRectIntegral

#define IRCGPointIsAbovePoint irCGPointIsAbovePoint

#define IRCGDelta IRDelta

#define IRCGRectGetGlobalMidXY irCGRectGetCenterOfRectFrame
#define IRCGRectGetLocalMidXY irCGRectGetCenterOfRectBounds

#define irCGRectWithRectAndOrigin(aRect, anOrigin) ((CGRect){ anOrigin, aRect.size });

#define IRCGRectGetInsetRect(aRect, aPadding) CGRectInset(aRect, aPadding, aPadding)

#define IRCGRectMoveToPoint irCGRectWithRectAndOrigin
#define IRCGRectTranslate CGRectOffset
#define IRCGDeltaMakeFromPoints IRDeltaFromPoints

#define IRCGRectMakeWithWidthAndHeight(aWidth, aHeight) CGRectMake(0, 0, aWidth, aHeight)

#define IRCGRectScale(aRect, aWidth, aHeight, anAnchor, flipped) IRCGRectAlignToRect(IRCGRectMakeWithWidthAndHeight(aWidth, aHeight), aRect, anAnchor, flipped)

#define IRCGDumpRect(aRect, aMessage) irDumpLog(aRect, aMessage)
#define IRCGDumpPoint(aPoint, aMessage) irDumpLog(aPoint, aMessage)
#define IRCGDumpSize(aSize, aMessage) irDumpLog(aSize, aMessage)
#define IRCGDumpExtremes(aRect, aMessage) irDumpLog(aRect, aMessage)

#endif
