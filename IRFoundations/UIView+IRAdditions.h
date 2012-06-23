//
//  UIView+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 8/3/11.
//  Copyright 2011 Waveface. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (IRAdditions)

- (UIView *) irFirstResponderInView;
- (NSArray *) irSubviewsWithPredicate:(NSPredicate *)aPredicate;

- (UIView *) irAncestorInView:(UIView *)aView;	//	Returns the enclosing subview in aView; if aView == self.superview, returns self

- (BOOL) irRemoveAnimationsRecusively:(BOOL)recursive;

@end

#import "NSArray+IRAdditions.h"
#import "CGGeometry+IRAdditions.h"

extern IRArrayMapCallback irMapFrameValuesFromViews (void);
extern IRArrayMapCallback irMapBoundsValuesFromViews (void);
extern IRArrayMapCallback irMapOriginValuesFromRectValues (void);
extern IRArrayMapCallback irMapCenterPointValuesFromRectValues (void);
