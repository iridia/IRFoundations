//
//  CGGeometry+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/13/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "CGGeometry+IRAdditions.h"





CGFloat (*irAnchorProcessorsX[])(CGRect) = {

	&CGRectGetMidX, &CGRectGetMidX, &CGRectGetMaxX,
	&CGRectGetMaxX, &CGRectGetMaxX, &CGRectGetMidX,
	&CGRectGetMinX, &CGRectGetMinX, &CGRectGetMinX
	
};

CGFloat (*irAnchorProcessorsYUnFlipped[])(CGRect) = {

	&CGRectGetMidY, &CGRectGetMaxY, &CGRectGetMaxY,
	&CGRectGetMidY, &CGRectGetMinY, &CGRectGetMinY,
	&CGRectGetMinY, &CGRectGetMidY, &CGRectGetMaxY
	
};

CGFloat (*irAnchorProcessorsYFlipped[])(CGRect) = {

	&CGRectGetMidY, &CGRectGetMinY, &CGRectGetMinY,
	&CGRectGetMidY, &CGRectGetMaxY, &CGRectGetMaxY,
	&CGRectGetMaxY, &CGRectGetMidY, &CGRectGetMinY
	
};










#if 0

IRLine IRLineMake(CGPoint origin, CGPoint destination, CGFloat width, UIColor *color) {

	IRLine theLine;
	
	theLine.origin = origin;
	theLine.destination = destination;
	theLine.width = width;
	theLine.color = [color retain];
	
	return theLine;
	
}

IRBorder IRBorderMake (IREdge edge, IRBorderType type, CGFloat width, UIColor *color) {
	
	IRBorder theBorder;
	
	theBorder.edge = edge;
	theBorder.type = type;
	theBorder.width = width;
	theBorder.color = [color retain];
	
	return theBorder;
	
}

IRShadow IRShadowMake(IREdge edge, CGPoint offset, CGFloat spread, UIColor *color) {

	IRCGShadow theShadow;
	
	theShadow.edge = edge;
	theShadow.offset = offset;
	theShadow.spread = spread;
	theShadow.color = [color retain];
	
	return theShadow;
	
}

#endif





CGPoint irCGRectGetCenterOfRectFrame (CGRect aRect) {

	return (CGPoint) { CGRectGetMidX(aRect), CGRectGetMidY(aRect) };

}

CGPoint irCGRectGetCenterOfRectBounds (CGRect aRect) {

	aRect = CGRectStandardize(aRect);
	aRect.origin = CGPointZero;

	return (CGPoint) { CGRectGetMidX(aRect), CGRectGetMidY(aRect) };

}





BOOL irCGPointIsAbovePoint(CGPoint aPoint, CGPoint referencedPoint, BOOL flipped) {
	
	if (flipped) return (aPoint.y < referencedPoint.y);
	return (aPoint.y > referencedPoint.y);
	
}





IRAnchor IRAnchorForEdge (IREdge edge) {
	
	switch (edge) {

		case IRCGEdgeTop: return IRCGTranslateAlignTypeTop;
		case IRCGEdgeRight: return IRCGTranslateAlignTypeRight;
		case IRCGEdgeBottom: return IRCGTranslateAlignTypeBottom;
		case IRCGEdgeLeft: return IRCGTranslateAlignTypeLeft;
		default: return IRCGTranslateAlignTypeCenter;

	}
	
}





CGRect IRCGSizeGetCenteredInRect(CGSize enclosedSize, CGRect enclosingRect, CGFloat minimalPadding, BOOL flipped) {

	float enclosedRectAspectRatio = enclosedSize.width / enclosedSize.height;
	
	CGSize maximumEnclosedSizeSize = CGSizeMake(
					    
		enclosingRect.size.width - (2 * minimalPadding),
		enclosingRect.size.height - (2 * minimalPadding)
    
	);
	
	CGSize currentEnclosedSizeSize = CGSizeMake(
	
		enclosedSize.width,
		enclosedSize.height
	
	);
	
	if (currentEnclosedSizeSize.width > maximumEnclosedSizeSize.width)
	currentEnclosedSizeSize = CGSizeMake(
	
		maximumEnclosedSizeSize.width,
		maximumEnclosedSizeSize.width / enclosedRectAspectRatio
		
	);
	
	if (currentEnclosedSizeSize.height > maximumEnclosedSizeSize.height)
	currentEnclosedSizeSize = CGSizeMake(
	
		maximumEnclosedSizeSize.height * enclosedRectAspectRatio, 
		maximumEnclosedSizeSize.height
	
	);
	
	return CGRectMake(
				
		enclosingRect.origin.x + ((enclosingRect.size.width - currentEnclosedSizeSize.width) / 2), 
		enclosingRect.origin.y + (flipped ? 1 : -1) * ((enclosingRect.size.height - currentEnclosedSizeSize.height) / 2), 
		currentEnclosedSizeSize.width, 
		currentEnclosedSizeSize.height
				
	);

}





IRDelta IRDeltaMake (CGFloat deltaX, CGFloat deltaY) {

	return (IRDelta) { deltaX, deltaY };

}

IRDelta IRDeltaFromSize (CGSize aSize) {

	return (IRDelta) { aSize.width, aSize.height };

}

IRDelta IRDeltaFromPoints(CGPoint fromPoint, CGPoint toPoint) {

	return (IRDelta) {
	
		toPoint.x - fromPoint.x,
		toPoint.y - fromPoint.y
		
	};

}

IRDelta IRDeltaFromRectSizes(CGRect fromRect, CGRect toRect) {

	return (IRDelta) {
	
		CGRectGetWidth(toRect) - CGRectGetWidth(fromRect),
		CGRectGetHeight(toRect) - CGRectGetHeight(fromRect)
	
	};

}





CGRect irCGRectApplyDelta (CGRect aRect, IRDelta aDelta) {

	return CGRectOffset(aRect, aDelta.x, aDelta.y);

}

CGRect irCGRectApplySizeDelta (CGRect aRect, IRDelta aDelta) {

	aRect.size.width += aDelta.x;
	aRect.size.height += aDelta.y;
	return aRect;

}

CGRect irCGRectApplyOrigin (CGRect aRect, CGPoint anOrigin) {

	aRect.origin = anOrigin;
	return aRect;

}

CGPoint irCGRectAnchor (CGRect aRect, IRAnchor anchor, BOOL flipped) {

	return (CGPoint) {

		(irAnchorProcessorsX)[anchor](aRect),
		(flipped ? irAnchorProcessorsYFlipped : irAnchorProcessorsYUnFlipped)[anchor](aRect)
		
	};
	
}

CGPoint irUnitPointForAnchor (IRAnchor anchor, BOOL flipped) {

	return irCGRectAnchor(CGRectMake(0, 0, 1, 1), anchor, flipped);

}





CGRect IRCGRectAlignToRect (CGRect theRect, CGRect referenceRect, IRAnchor anchor, BOOL flipped) {

	return irCGRectApplyDelta(theRect, IRDeltaFromPoints(
		
		irCGRectAnchor(theRect, anchor, flipped),
		irCGRectAnchor(referenceRect, anchor, flipped)
	
	));

}





CGRect irAnchoredRectFromEdge (CGRect aRect, IREdge anEdge, CGFloat widthOrHeight) {

	CGRect finalRect = aRect;

	if (anEdge | IREdgeHorizontal) {

		finalRect.size.height = widthOrHeight;
	
	} else if (anEdge | IREdgeVertical) {

		finalRect.size.width = widthOrHeight;
	
	}
	
	return IRCGRectAlignToRect(finalRect, aRect, IRAnchorForEdge(anEdge), YES);

}





CGFloat irDistanceFromRectToPoint (CGRect aRect, CGPoint aPoint, IRAnchor anchor) {

	IRDelta aDelta = IRDeltaFromPoints(irCGRectAnchor(aRect, anchor, YES), aPoint);
	
	return sqrt(pow(aDelta.x, 2) + pow(aDelta.y, 2));

}





CGRect IRUnitRectWithRectAndEdgeInsets (CGRect aRect, IREdgeInsets edgeInsets) {

	CGRect referencedRect = irCGRectApplyOrigin(CGRectStandardize(aRect), CGPointZero); 
	
	CGRect returnedRect = CGRectMake(
	
		(edgeInsets.left / referencedRect.size.width),
		(edgeInsets.top / referencedRect.size.height),
		((referencedRect.size.width - edgeInsets.right - edgeInsets.left) / referencedRect.size.width),
		((referencedRect.size.height - edgeInsets.bottom - edgeInsets.top) / referencedRect.size.height)
	
	);

	return returnedRect;
	
}





CGPoint irCGPointAddPoint(CGPoint aPoint, CGPoint anotherPoint) {

	return (CGPoint) {
	
		aPoint.x + anotherPoint.x,
		aPoint.y + anotherPoint.y
	
	};

}





NSString * irDumpImpl (const char *encodedString, void * aPointer) {

	if (strcmp(encodedString, @encode(CGRect)) == 0)
	return NSStringFromCGRect(*(CGRect*)aPointer);

	if (strcmp(encodedString, @encode(CGPoint)) == 0)
	return NSStringFromCGPoint(*(CGPoint*)aPointer);
	
	if (strcmp(encodedString, @encode(CGSize)) == 0)
	return NSStringFromCGSize(*(CGSize*)aPointer);
	
	return @"(Unknown)";

}