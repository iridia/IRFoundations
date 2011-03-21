//
//  IRActionSheet.h
//  Milk
//
//  Created by Evadne Wu on 2/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IRActionSheet : UIActionSheet

@property (nonatomic, readwrite, assign) CGRect lastShownInRect;
@property (nonatomic, readwrite, assign) UIView *lastShownInView;
@property (nonatomic, readwrite, assign) BOOL canUseCustomReshowing;

- (void) prepareForReshowingIfAppropriate;
- (void) reshowIfAppropriate;	// re-show the action sheet from the rect in a view, if the action was shown in that rect / view

@end
