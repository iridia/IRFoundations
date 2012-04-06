//
//  IRPaginatedView.h
//  IRFoundations
//
//  Created by Evadne Wu on 4/17/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Foundation+IRAdditions.h"

@class IRPaginatedView;
@protocol IRPaginatedViewDelegate <NSObject>

- (NSUInteger) numberOfViewsInPaginatedView:(IRPaginatedView *)paginatedView;
- (UIView *) viewForPaginatedView:(IRPaginatedView *)paginatedView atIndex:(NSUInteger)index;
- (UIViewController *) viewControllerForSubviewAtIndex:(NSUInteger)index inPaginatedView:(IRPaginatedView *)paginatedView;
//	If returned, the view controller gets -viewWillAppear:, -viewDidAppear:, -viewWillDisappear:, -viewDidDisappear:.

@optional
- (void) paginatedView:(IRPaginatedView *)paginatedView willShowView:(UIView *)aView atIndex:(NSUInteger)index;
- (void) paginatedView:(IRPaginatedView *)paginatedView didShowView:(UIView *)aView atIndex:(NSUInteger)index;

@end





@interface IRPaginatedView : UIView

- (void) reloadViews;

@property (nonatomic, readwrite, assign) NSUInteger currentPage;
@property (nonatomic, readwrite, assign) NSUInteger numberOfPages;

@property (nonatomic, readwrite, assign) IBOutlet id<IRPaginatedViewDelegate> delegate;
@property (nonatomic, readwrite, assign) CGFloat horizontalSpacing; // defaults to 0.0

@property (nonatomic, readonly, retain) UIScrollView *scrollView; // Please don’t do evil

- (void) scrollToPageAtIndex:(NSUInteger)anIndex animated:(BOOL)animate;
- (UIView *) existingPageAtIndex:(NSUInteger)anIndex;
- (CGRect) pageRectForIndex:(NSInteger)anIndex;

@property (nonatomic, readwrite, copy) BOOL (^onPointInsideWithEvent)(CGPoint aPoint, UIEvent *anEvent, BOOL superAnswer);

@end
