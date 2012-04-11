//
//  MLTransparentToolbar.h
//  IRFoundations
//
//  Created by Evadne Wu on 12/1/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//
//  Transparent Toolbar Code
//  http://stackoverflow.com/questions/2468831/couldnt-uitoolbar-be-transparent
//

#import <UIKit/UIKit.h>





@class IRTransparentToolbar;
@protocol IRTransparentToolbarDelegate <NSObject>

@optional

- (BOOL) toolbar:(IRTransparentToolbar *)toolBar shouldStretchItem:(UIBarButtonItem *)item atIndex:(NSUInteger)index;

//	Implement this method and return YES selectively.  The items you agree to stretch will be given additional space.

@end





@interface IRTransparentToolbar : UIToolbar {

}

@property (nonatomic, readwrite, assign) id<IRTransparentToolbarDelegate> delegate;
@property (nonatomic, readwrite, assign) float leftPadding;
@property (nonatomic, readwrite, assign) float itemPadding;
@property (nonatomic, readwrite, assign) float rightPadding;

@property (nonatomic, readwrite, assign) BOOL usesCustomLayout; // defaults to YES

@end
