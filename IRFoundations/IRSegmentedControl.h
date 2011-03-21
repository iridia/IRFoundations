//
//  MLFlushGlowingSegmentedControl.h
//  Milk
//
//  Created by Evadne Wu on 12/1/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "IRTransparentToolbar.h"
#import "IRSegmentedControlSegment.h"





@class IRSegmentedControl;
@protocol IRSegmentedControlDelegate

- (void) segmentedControl:(IRSegmentedControl *)control didSelectSegmentAtIndex:(NSUInteger)index;

@end


@interface IRSegmentedControl : UIView <IRSegmentedControlSegmentDelegate> {

}

@property (nonatomic, readwrite, assign) id<IRSegmentedControlDelegate> delegate;

@property (nonatomic, readwrite, retain) NSArray *items;
@property (nonatomic, readonly, retain) IRTransparentToolbar *toolbar;
@property (nonatomic, readwrite, assign) NSInteger selectedSegmentIndex;

@property (nonatomic, readwrite, assign) BOOL usesAlternateImages;


- (IRSegmentedControlSegment *) segmentAtIndex:(NSUInteger)inIndex;
- (NSUInteger) indexOfSegment:(IRSegmentedControlSegment *)inSegment;


- (void) setTarget:(id)inTarget action:(SEL)inAction forSegmentAtIndex:(NSUInteger)inIndex;
- (void) setActive:(BOOL)inActive forSegmentAtIndex:(NSUInteger)inIndex animated:(BOOL)inAnimated;
- (void) setHighlighted:(BOOL)inHighlighted forSegmentAtIndex:(NSUInteger)inIndex animated:(BOOL)inAnimated;

@end




