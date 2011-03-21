//
//  IRSegmentedControlSegment.h
//  Milk
//
//  Created by Evadne Wu on 12/1/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>





@protocol IRSegmentedControlSegmentDelegate

- (void) handleSegmentTap:(id)sender;

@end


@interface IRSegmentedControlSegment : UIView {
	
}

- (id) initWithFrame:(CGRect)inFrame image:(UIImage *)inImage highlightedImage:(UIImage *)inHighlightedImage activeBackdrop:(UIImage *)inActiveBackdrop;

@property (nonatomic, readwrite, assign) id<IRSegmentedControlSegmentDelegate> delegate;

@property (nonatomic, readwrite, retain) UIButton *trackingButton;
@property (nonatomic, readwrite, retain) UIImage *image;
@property (nonatomic, readwrite, retain) UIImage *alternateImage;

@property (nonatomic, readwrite, retain) UIImage *highlightedImage;
@property (nonatomic, readwrite, retain) UIImage *alternateHighlightedImage;

@property (nonatomic, readwrite, retain) UIImage *activeBackdropImage;

@property (nonatomic, readwrite, assign) BOOL usesAlternateImages;

@property (nonatomic, readwrite, assign) BOOL active;
@property (nonatomic, readwrite, assign) BOOL highlighted;





- (void) setTrackingButtonTarget:(id)inTarget action:(SEL)inAction;





- (void) setActive:(BOOL)inActive animated:(BOOL)inAnimated;
- (void) setHighlighted:(BOOL)inHighlighted animated:(BOOL)inAnimated;
- (void) transitionAnimated:(BOOL)inAnimated;

- (void) transition;
- (void) bestowImages;

@end




