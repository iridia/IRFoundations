//
//  IRConcaveView.h
//  Milk
//
//  Created by Evadne Wu on 1/29/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRView.h"
#import "IRShadow.h"

@interface IRConcaveView : IRView

@property (nonatomic, readwrite, retain) IRShadow *innerShadow;

//	The inner shadow is drawn by CoreGraphics.

@end
