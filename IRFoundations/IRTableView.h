//
//  MLTableView.h
//  IRFoundations
//
//  Created by Evadne Wu on 1/4/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "Foundation+IRAdditions.h"

#ifndef __IRTableView__
#define __IRTableView__

typedef enum {

	IRTableViewPullDownRefreshStateInactive,
	IRTableViewPullDownRefreshStateBegan,
	IRTableViewPullDownRefreshStateActive

} IRTableViewPullDownRefreshState;

#endif










@interface IRTableView : UITableView <UITableViewDelegate>

//	This class is made to alleviate a plethora of private classes that were subclasses merely to configure.





# pragma mark -
# pragma mark Encoding and Swizzling

+ (id) tableViewWithEncodedDataOfObject:(UITableView *)inTableView;
+ (id) tableViewWithEncodedDataOfObject:(UITableView *)inTableView ofClass:(Class)inClass;

//	Useful and very safe object swizzling, useful when making a table view from an existing UITableViewController.
//	Uses NSKeyedArchiver, NSKeyedUnarchiver.  Makes a new object using the encoded data of inTableView
//	by calling -initWithCoder:.





# pragma mark -
# pragma mark Permitting Scrolling

@property (nonatomic, readwrite, copy) BOOL (^onTouchesShouldBeginWithEventInContentView)(NSSet *touches, UIEvent *event, UIView *contentView);

//	If not nil, touchesShouldBegin:withEvent:inContentView: returns the value from the block
//	Else, returns value from superclass implementation


@property (nonatomic, readwrite, copy) BOOL (^onTouchesShouldCancelInContentView)(UIView *contentView);

//	If not nil, touchesShouldCancel: returns the value from the block;
//	Else, returns value from superclass implementation





# pragma mark -
# pragma mark Scroll Delegation

@property (nonatomic, readwrite, copy) void (^onScroll)();
@property (nonatomic, readwrite, copy) void (^onZoom)();
@property (nonatomic, readwrite, copy) void (^onDragBegin)();
@property (nonatomic, readwrite, copy) void (^onDragEnd)(BOOL willDecelerate);
@property (nonatomic, readwrite, copy) void (^onDecelerationBegin)();
@property (nonatomic, readwrite, copy) void (^onDecelerationEnd)();
@property (nonatomic, readwrite, copy) void (^onScrollAnimationEnd)();





# pragma mark -
# pragma mark Pulling Down to Refresh

@property (nonatomic, readonly, assign) IRTableViewPullDownRefreshState pullDownToRefreshState;

//	Exposed for advanced interaction handling.


@property (nonatomic, readwrite, retain) UIView *pullDownHeaderView;

//	The view to be revealed when the user pulls the table view down.
//	Must not be nil for pulling-down-to-refresh to work.


@property (nonatomic, readwrite, copy) void (^onPullDownBegin)();

//	A hook that allows custom animation or other processing to begin when the header view is being revealed.
//	Called if not nil.


@property (nonatomic, readwrite, copy) void (^onPullDownMove)(CGFloat progress);

//	Progress is 0 to 1.  Called whenever the user scrolls (pulls down) before the view is totally revealed.
//	Will be called multiple times, if not nil.


@property (nonatomic, readwrite, copy) void (^onPullDownEnd)(BOOL finished);

//	Must not be nil.  Called when the user releases the table view.
//	requestDidFinish will be YES if the header view is fully revealed, and will not be scrolled away.
//	otherwise, it’s NO if the user releases touch before the header view is fully revealed.
//	In that case the header view will be scrolled away.


- (void) resetPullDown;

//	Called when the interested object has finished doing work that fullfills the context of a refresh.
//	Scrolls header view away, if appropriate.


@property (nonatomic, readwrite, copy) void (^onPullDownReset)();

//	Takes care of resetting the pulldown.  If not nil, called when -resetPullDown is called.
//	Useful for certain non-retained-by-caller UI elements.


@property (nonatomic, readwrite, assign) BOOL pullDownHeaderViewOverlaysContentView;

//	Unimplemented.  Determines whether the header follows the table, or if it overlays other subviews.





# pragma mark -
# pragma mark Delayed Performing

extern NSString * const IRTableViewWillSuspendPerformingBlocksNotification;
extern NSString * const IRTableViewWillResumePerformingBlocksNotification;

@property (nonatomic, readonly, assign) BOOL delayedPerformQueueSuspended;

- (void) performBlockOnInteractionEventsEnd:(void(^)(void))block;

//	This helps a lot when you have a data source that ought to be updated, but can’t be updated without stopping the dragging or tracking.  Toss a block here, and it will be performed when appropriate.

- (void) suspendDelayedPerformQueue;
- (void) resumeDelayedPerformQueue;
- (void) clearDelayedPerformQueue;





# pragma mark -
# pragma Conveniences

- (NSArray *) irRectsForVisibleCells;
- (void) irOffsetSafely:(CGPoint)offset animated:(BOOL)animated;

- (CGRect) irRectForRowAtIndexPathOrCGRectNull:(NSIndexPath *)anIndexPath;




# pragma mark -
# pragma mark Other Behavior

@property (nonatomic, readwrite, copy) void (^onLayoutSubviews)();

- (UIEdgeInsets) actualContentInset;





@end





