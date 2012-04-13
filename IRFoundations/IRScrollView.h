//
//  WAScrollView.h
//  wammer
//
//  Created by Evadne Wu on 1/30/12.
//  Copyright (c) 2012 Waveface. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IRScrollView : UIScrollView

@property (nonatomic, readwrite, copy) BOOL (^onTouchesShouldBeginWithEventInContentView)(NSSet *touches, UIEvent *event, UIView *view);
@property (nonatomic, readwrite, copy) BOOL (^onTouchesShouldCancelInContentView)(UIView *view);
@property (nonatomic, readwrite, copy) BOOL (^onGestureRecognizerShouldBegin)(UIGestureRecognizer *recognizer, BOOL superAnswer);
@property (nonatomic, readwrite, copy) BOOL (^onGestureRecognizerShouldReceiveTouch)(UIGestureRecognizer *recognizer, UITouch *touch, BOOL superAnswer);
@property (nonatomic, readwrite, copy) BOOL (^onGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer)(UIGestureRecognizer *recognizer, UIGestureRecognizer *otherRecognizer, BOOL superAnswer);

@end
