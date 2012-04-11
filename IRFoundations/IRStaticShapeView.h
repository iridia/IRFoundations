//
//  IROptionallyDynamicShapeView.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

#import "CGGeometry+IRAdditions.h"

@protocol IRStaticShapeViewDataSource

@property (nonatomic, readwrite, retain) UIColor *backgroundColor;
@property (nonatomic, readwrite, retain) UIBezierPath *path;
@property (nonatomic, readwrite, retain) UIColor *shadowColor;
@property (nonatomic, readwrite, assign) CGSize shadowOffset;
@property (nonatomic, readwrite, assign) CGFloat shadowSpread;
@property (nonatomic, readwrite, retain) UIColor *fillColor;

@end

@class IRStaticShapeViewDrawingView;
@interface IRStaticShapeView : UIView <IRStaticShapeViewDataSource>

@property (nonatomic, readonly, retain) IRStaticShapeViewDrawingView *drawingView;

@end

@interface IRStaticShapeViewDrawingView : UIView

@property (nonatomic, readwrite, assign) NSObject<IRStaticShapeViewDataSource> *dataSource;

@end





//	This static view is used to host a CGPath, for occassions where you want a static and stretchable view that hosts a CGPath, and a CAShapeLayer is too expensive because its .path is not .content, only the latter being stretchable.

//	Ideally you substitute this and a CAShapeLayer to achieve partial animation when permissible.  This class will be extended in the future.

