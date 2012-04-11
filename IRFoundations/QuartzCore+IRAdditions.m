//
//  QuartzCore+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "QuartzCore+IRAdditions.h"


void IRCATransact(void(^aBlock)(void)) {

	[CATransaction begin];
	[CATransaction setAnimationDuration:0.0];
	[CATransaction setDisableActions:YES];
	
	if (aBlock)
	aBlock();

	[CATransaction commit];

}

CGRect IRGravitize (CGRect enclosingRect, CGSize contentSize, NSString *gravity) {
	
	CGRect (^align)(IRAnchor) = ^ (IRAnchor anAnchor) {
		return IRCGRectAlignToRect((CGRect){ CGPointZero, contentSize }, enclosingRect, anAnchor, YES);
	};

	if ([gravity isEqualToString:kCAGravityTopLeft])
		return align(irTopLeft);
	
	if ([gravity isEqualToString:kCAGravityTop])
		return align(irTop);
	
	if ([gravity isEqualToString:kCAGravityTopRight])
		return align(irTopRight);
	
	if ([gravity isEqualToString:kCAGravityLeft])
		return align(irLeft);
		
	if ([gravity isEqualToString:kCAGravityCenter])
		return align(irCenter);
	
	if ([gravity isEqualToString:kCAGravityRight])
		return align(irRight);
		
	if ([gravity isEqualToString:kCAGravityBottomLeft])
		return align(irBottomLeft);
	
	if ([gravity isEqualToString:kCAGravityBottom])
		return align(irBottom);
	
	if ([gravity isEqualToString:kCAGravityBottomRight])
		return align(irBottomRight);
	
	BOOL isAspectFit = [gravity isEqualToString:kCAGravityResizeAspect];
	BOOL isAspectFill = [gravity isEqualToString:kCAGravityResizeAspectFill];
	
	if ((!isAspectFit && !isAspectFill) || (isAspectFit && isAspectFill))
		return enclosingRect;
		
	CGFloat imageSizeRatio = contentSize.width / contentSize.height;
	CGFloat imageFrameRatio = enclosingRect.size.width / enclosingRect.size.height;
	
	if (imageSizeRatio == imageFrameRatio)
		return enclosingRect;
	
	CGSize heightFittingImageSize = (CGSize){
		CGRectGetHeight(enclosingRect) * imageSizeRatio,
		CGRectGetHeight(enclosingRect)
	};
	
	CGSize widthFittingImageSize = (CGSize){
		CGRectGetWidth(enclosingRect),
		CGRectGetWidth(enclosingRect) / imageSizeRatio
	};
	
	CGRect heightFittingImageFrame = (CGRect){
		(CGPoint) { 0.5f * (enclosingRect.size.width - heightFittingImageSize.width), 0 },
		heightFittingImageSize	
	};

	CGRect widthFittingImageFrame = (CGRect){
		(CGPoint) { 0, 0.5f * (enclosingRect.size.height - widthFittingImageSize.height) },
		widthFittingImageSize	
	};
	
	if (imageSizeRatio < imageFrameRatio)
		return isAspectFit ? heightFittingImageFrame : widthFittingImageFrame;
	else // imageSizeRatio > imageFrameRatio
		return isAspectFit ? widthFittingImageFrame : heightFittingImageFrame;
	
}
