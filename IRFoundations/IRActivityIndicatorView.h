//
//  IRActivityIndicatorView.h
//  IRFoundations
//
//  Created by Evadne Wu on 1/24/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IRActivityIndicatorView : UIActivityIndicatorView

@property (nonatomic, readwrite, assign, getter=isAnimating) BOOL animating;

@end
