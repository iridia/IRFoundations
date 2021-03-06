//
//  WAStackView.h
//  wammer
//
//  Created by Evadne Wu on 12/21/11.
//  Copyright (c) 2011 Waveface. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRScrollView.h"

@class IRStackView;
@protocol IRStackViewDelegate <NSObject>

- (BOOL) stackView:(IRStackView *)aStackView shouldStretchElement:(UIView *)anElement;
- (CGSize) sizeThatFitsElement:(UIView *)anElement inStackView:(IRStackView *)aStackView;

@end


@interface IRStackView : IRScrollView

@property (nonatomic, readwrite, assign) id <UIScrollViewDelegate, IRStackViewDelegate> delegate;	//	the aptly-named `delegate` is used by the scrollview

@property (nonatomic, readwrite, copy) void (^onDidLayoutSubviews)(void);

- (NSMutableArray *) mutableStackElements;

- (void) addStackElements:(NSSet *)objects;
- (void) addStackElementsObject:(UIView *)object;
- (void) removeStackElements:(NSSet *)objects;
- (void) removeStackElementsAtIndexes:(NSIndexSet *)indexes;
- (void) removeStackElementsObject:(UIView *)object;

- (void) beginPostponingStackElementLayout;
- (void) endPostponingStackElementLayout;
- (BOOL) isPostponingStackElementLayout;

@end
