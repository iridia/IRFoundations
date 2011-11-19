//
//  UIApplication+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 11/18/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (IRAdditions)

- (void) irBeginIgnoringStatusBarAppearanceRequests;
- (void) irEndIgnoringStatusBarAppearanceRequests;

@end
