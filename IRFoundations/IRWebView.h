//
//  IRWebView.h
//  Milk
//
//  Created by Evadne Wu on 2/16/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IRWebView : UIWebView

- (NSString *) executeJavaScriptWithContentsOfFile:(NSURL *)aFileURL;
- (void) injectCSSWithContentsOfFile:(NSURL *)aFileURL;

- (void) lockViewportScaling;

@property (nonatomic, readonly, retain) UIView *overlayView;
@property (nonatomic, readonly, retain) UIView *backgroundView;

@end
