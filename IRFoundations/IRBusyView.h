//
//  IRBusyView.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef __IRBusyView__
#define __IRBusyView__

typedef enum {

	IRBusyViewStyleDefaultSpinner

} IRBusyViewStyle;

#endif

@interface IRBusyView : UIView

@property (nonatomic, readwrite, retain) UIView *contentView;
@property (nonatomic, readwrite, retain) UIView *busyOverlayView;
@property (nonatomic, readwrite, assign) IRBusyViewStyle style;

+ (IRBusyView *) wrappedBusyViewForView:(UIView *)wrappedView withStyle:(IRBusyViewStyle)aStyle;
- (void) configureForPresetStyle:(IRBusyViewStyle)aStyle; // preset

@end
