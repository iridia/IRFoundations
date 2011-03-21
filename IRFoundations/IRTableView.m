//
//  MLTableView.m
//  Milk
//
//  Created by Evadne Wu on 1/4/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRTableView.h"


@interface IRTableView ()

@property (nonatomic, readwrite, assign) UIEdgeInsets originalEdgeInsets;
@property (nonatomic, readwrite, assign) id intendedDelegate;

- (void) configure;


@property (nonatomic, readwrite, assign) BOOL pullDownToRefreshEnabled;
@property (nonatomic, readwrite, assign) BOOL pullDownToRefreshRequestIsAllowed;

@property (nonatomic, readwrite, assign) BOOL pullDownToRefreshRequestBegan;
@property (nonatomic, readwrite, assign) BOOL pullDownToRefreshRequestOngoing;
@property (nonatomic, readwrite, assign) BOOL pullDownToRefreshRequestProcessing;


@property (nonatomic, readwrite, assign) IRTableViewPullDownRefreshState pullDownToRefreshState;

- (void) layoutPullDownHeaderView;
- (BOOL) isShowingContentsAboveTheFold;
- (BOOL) contentOffsetAllowsVisiblePullToRefreshHeader;
- (BOOL) contentOffsetAllowsFullPullToRefreshHeader;


@property (nonatomic, readwrite, assign) dispatch_queue_t delayedPerformQueue;
@property (nonatomic, readwrite, assign) BOOL delayedPerformQueueSuspended;
@property (nonatomic, readwrite, assign) BOOL delayedPerformQueueFinalizing;

@end










@implementation IRTableView

@synthesize onTouchesShouldBeginWithEventInContentView, onTouchesShouldCancelInContentView;

@synthesize onScroll, onZoom, onDragBegin, onDragEnd, onDecelerationBegin, onDecelerationEnd, onScrollAnimationEnd;

@synthesize originalEdgeInsets;
@synthesize intendedDelegate;

@synthesize pullDownToRefreshEnabled, pullDownToRefreshRequestIsAllowed;

@synthesize pullDownToRefreshRequestBegan, pullDownToRefreshRequestOngoing, pullDownToRefreshRequestProcessing, pullDownToRefreshState;

@synthesize delayedPerformQueue, delayedPerformQueueSuspended, delayedPerformQueueFinalizing;

@synthesize pullDownHeaderView, onPullDownBegin, onPullDownMove, onPullDownEnd, onPullDownReset, pullDownHeaderViewOverlaysContentView;





# pragma mark -
# pragma mark Initialization

+ (id) tableViewWithEncodedDataOfObject:(UITableView *)inTableView ofClass:(Class)inClass {

	NSMutableData *tableViewData = [NSMutableData data];
	NSKeyedArchiver *tableViewArchiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:tableViewData] autorelease]; 

	[tableViewArchiver encodeObject:inTableView];
	[tableViewArchiver finishEncoding];
	
	NSKeyedUnarchiver *tableViewUnarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:tableViewData] autorelease];

	IRTableView *returnedTableView = [[[inClass alloc] initWithCoder:tableViewUnarchiver] autorelease];
	if (!returnedTableView) return nil;

	return returnedTableView;

}

+ (id) tableViewWithEncodedDataOfObject:(UITableView *)inTableView {

	return [self tableViewWithEncodedDataOfObject:inTableView ofClass:[self class]];

}





- (id) initWithCoder:(NSCoder *)aDecoder {

	self = [super initWithCoder:aDecoder];
	if (!self) return nil;
	
	[self configure];
		
	return self;

}
- (id) initWithFrame:(CGRect)frame style:(UITableViewStyle)style {

	self = [super initWithFrame:frame style:style];
	if (!self) return nil;
	
	[self configure];
	
	return self;

}

- (void) configure {

	[super setDelegate:self];
	
	self.pullDownToRefreshEnabled = NO;
	self.pullDownToRefreshRequestIsAllowed = NO;
	self.pullDownToRefreshRequestOngoing = NO;
	self.pullDownToRefreshRequestProcessing = NO;
	self.pullDownToRefreshState = IRTableViewPullDownRefreshStateInactive;

	self.delayedPerformQueue = dispatch_queue_create("iridia.tableViewController.performAfterInteractionEvents", NULL);
	self.delayedPerformQueueSuspended = NO;

}

- (void) clearDelayedPerformQueue {

	BOOL wasFinalizing = self.delayedPerformQueueFinalizing;
	BOOL wasSuspended = self.delayedPerformQueueSuspended;

	self.delayedPerformQueueFinalizing = YES;
	[self resumeDelayedPerformQueue];
	
	self.delayedPerformQueueFinalizing = wasFinalizing;
	
	if (wasSuspended) {
	
		self.delayedPerformQueueSuspended = NO;
		[self suspendDelayedPerformQueue];
	
	} else {
	
		self.delayedPerformQueueSuspended = NO;
	
	}

}

- (void) dealloc {

	self.delayedPerformQueueFinalizing = YES;
	[self resumeDelayedPerformQueue];

	dispatch_release(self.delayedPerformQueue);
	self.delayedPerformQueue = nil;

	self.onTouchesShouldBeginWithEventInContentView = nil;
	self.onTouchesShouldCancelInContentView = nil;
	
	self.pullDownHeaderView = nil;
	self.onPullDownBegin = nil;
	self.onPullDownMove = nil;
	self.onPullDownEnd = nil;
	self.onPullDownReset = nil;
	
	self.onScroll = nil;
	self.onZoom = nil;
	self.onDragBegin = nil;
	self.onDragEnd = nil;
	self.onDecelerationBegin = nil;
	self.onDecelerationEnd = nil;
	self.onScrollAnimationEnd = nil;
	
	[super dealloc];

}





# pragma mark -
# pragma mark Layout

- (UIEdgeInsets) contentInset {

	UIEdgeInsets returnedInset = [super contentInset];
	
	if (self.pullDownHeaderView && (self.pullDownToRefreshState == IRTableViewPullDownRefreshStateActive))
	returnedInset.top -= self.pullDownHeaderView.frame.size.height;
	
	return returnedInset;

}

- (void) setContentInset:(UIEdgeInsets)inset {

	self.originalEdgeInsets = inset;
	
	UIEdgeInsets newContentInset = inset;
	
	if (self.pullDownHeaderView && (self.pullDownToRefreshState == IRTableViewPullDownRefreshStateActive))
	newContentInset.top += self.pullDownHeaderView.frame.size.height;
	
	[super setContentInset:newContentInset];

}






# pragma mark -
# pragma mark Delegation Forwarding

- (void) setDelegate:(id <UITableViewDelegate>)inDelegate {

//	Calling -setDelegate: of the superclass helps clean up the clogged machinery
//	It is expected that Apple implements some respondsToSelector: checking there

	self.intendedDelegate = inDelegate;
	[super setDelegate:self];

}

- (id) delegate {

	return self.intendedDelegate;

}

- (BOOL) respondsToSelector:(SEL)aSelector {

	if ([self.intendedDelegate respondsToSelector:aSelector])
	return YES;

	return [[super class] instancesRespondToSelector:aSelector];

}

- (id) forwardingTargetForSelector:(SEL)aSelector {

	if ([[super class] instancesRespondToSelector:aSelector])
	return self;
	
	if (self.intendedDelegate)
	if ([self.intendedDelegate respondsToSelector:aSelector])
	return self.intendedDelegate;
	
	return [super forwardingTargetForSelector:aSelector];

}





# pragma mark -
# pragma mark Touch Handling

- (BOOL) touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {

	if (onTouchesShouldBeginWithEventInContentView)
	return (onTouchesShouldBeginWithEventInContentView)(touches, event, view);
	
	return [super touchesShouldBegin:touches withEvent:event inContentView:view];

}

- (BOOL) touchesShouldCancelInContentView:(UIView *)view {

	if (onTouchesShouldCancelInContentView)
	return (onTouchesShouldCancelInContentView(view));
	
	return [super touchesShouldCancelInContentView:view];

}




# pragma mark -
# pragma mark Pulling down to refresh

- (void) refreshPullDownToRefreshEligibility {

	self.pullDownToRefreshEnabled = (self.pullDownHeaderView != nil) && (self.onPullDownEnd != nil);
	self.pullDownToRefreshRequestIsAllowed = self.pullDownToRefreshEnabled;

}

- (void) refreshPullDownToRefreshState {

	if (!self.pullDownHeaderView)
	return;
		
	if (!([super contentOffset].y < (-1 * self.originalEdgeInsets.top)))
	return;
	
	if (self.tracking) {
			
	//	Do not scroll when the user is using the scroll view!

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1LL * NSEC_PER_SEC), dispatch_get_main_queue(), ^ {

			[self refreshPullDownToRefreshState];

		});

		return;
	
	}
	
	if (!self.pullDownToRefreshRequestOngoing)
	[self flashScrollIndicators];
	
}

- (void) resetPullDown {

	[self refreshPullDownToRefreshEligibility];
	
	self.pullDownToRefreshState = IRTableViewPullDownRefreshStateInactive;
	
	[self retain];
	
	__block IRTableView *nonretainedSelf = self;

	void (^animationBlock)() = ^ {
	
		[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations: ^ {
		
			self.pullDownToRefreshState = IRTableViewPullDownRefreshStateInactive;
			[self setContentInset:self.originalEdgeInsets];

		} completion: ^ (BOOL finished) {
					
			if (!nonretainedSelf.window)
			return;
		
		//	self.pullDownHeaderView.hidden = YES;
			
			if (nonretainedSelf.onPullDownReset)
			nonretainedSelf.onPullDownReset();
			
			[nonretainedSelf refreshPullDownToRefreshState];			
			
			[nonretainedSelf autorelease];
		
		}];
	
	};
	
	if ([[NSThread currentThread] isEqual:[NSThread mainThread]]) {
	
		animationBlock();
	
	} else {
	
		dispatch_async(dispatch_get_main_queue(), animationBlock);
	
	}
	
}

- (void) setPullDownHeaderView:(UIView *)inView {

	if (inView == pullDownHeaderView) return;
	
	[pullDownHeaderView removeFromSuperview];
	
	[pullDownHeaderView release];
	pullDownHeaderView = [inView retain];
	
	[self addSubview:inView];
	[self layoutPullDownHeaderView];

//	The view is ALWAYS hidden unless if a request is in progress.
//	self.pullDownHeaderView.hidden = YES;
	
	[self refreshPullDownToRefreshEligibility];

}

- (void) setOnPullDownBegin:(void (^)())inBlock {

	if (inBlock == onPullDownBegin)
	return;
	
	[onPullDownBegin release];
	onPullDownBegin = [inBlock copy];
	
	[self refreshPullDownToRefreshEligibility];

}

- (void) setOnPullDownMove:(void (^)(CGFloat progressRatio))inBlock {

	if (inBlock == onPullDownMove)
	return;
	
	[onPullDownMove release];
	onPullDownMove = [inBlock copy];
	
	[self refreshPullDownToRefreshEligibility];

}

- (void) setOnPullDownEnd:(void (^)(BOOL requestDidFinish))inBlock {

	if (inBlock == onPullDownEnd)
	return;
	
	[onPullDownEnd release];
	onPullDownEnd = [inBlock copy];
	
	[self refreshPullDownToRefreshEligibility];

}

- (void) layoutSubviews {

	[super layoutSubviews];
	[self layoutPullDownHeaderView];

}

- (void) layoutPullDownHeaderView {

//	Since we reference the original inset, not the current inset, the header view will always be positioned correctly, and there is no need to call this multiple times.

	self.pullDownHeaderView.frame = CGRectMake(
	
		0,
		-1 * (self.pullDownHeaderView.frame.size.height + self.originalEdgeInsets.top),
		self.bounds.size.width,
		self.pullDownHeaderView.frame.size.height
	
	);
	
	self.pullDownHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;

}





# pragma mark -
# pragma mark Scrolling / Other Interactions

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {

	[self suspendDelayedPerformQueue];

//	self.pullDownHeaderView.hidden = !([self isShowingContentsAboveTheFold]);

	if (self.pullDownToRefreshState == IRTableViewPullDownRefreshStateInactive)
	if ([self isShowingContentsAboveTheFold])
	if ([self contentOffsetAllowsVisiblePullToRefreshHeader]) {

		self.pullDownToRefreshState = IRTableViewPullDownRefreshStateBegan;
	//	self.pullDownHeaderView.hidden = NO;
	
	}
	
	dispatch_async(dispatch_get_main_queue(), ^ {
	
		if ([self.intendedDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
		[self.intendedDelegate scrollViewWillBeginDragging:scrollView];

	});
	
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {

	if (self.pullDownToRefreshState == IRTableViewPullDownRefreshStateBegan)
	if ([self contentOffsetAllowsVisiblePullToRefreshHeader])
	dispatch_async(dispatch_get_main_queue(), ^ {
	
		if (self.onPullDownMove)
		self.onPullDownMove(
		
			MAX(0, MIN(1, ((-1 * ([super contentOffset].y + scrollView.contentInset.top)) / self.pullDownHeaderView.frame.size.height)))
		
		);
	
	});
	
	dispatch_async(dispatch_get_main_queue(), ^ {

		if ([self.intendedDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
		[self.intendedDelegate scrollViewDidScroll:scrollView];	
		
	});

}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

	if (!decelerate)
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_current_queue(), ^ {

		[self resumeDelayedPerformQueue];
	
	});

	if (decelerate)
	if (self.pullDownToRefreshState != IRTableViewPullDownRefreshStateActive)
	if ([self isShowingContentsAboveTheFold])
	if ([self contentOffsetAllowsFullPullToRefreshHeader]) {
	
		self.pullDownToRefreshState = IRTableViewPullDownRefreshStateActive;
		
		[UIView animateWithDuration:0.25 animations: ^ {
		
			[self setContentInset:self.originalEdgeInsets];				
		
		}];

		dispatch_async(dispatch_get_main_queue(), ^ {

			if (self.onPullDownEnd)
			self.onPullDownEnd(YES);

		});				
	
	}
	
	dispatch_async(dispatch_get_main_queue(), ^ {

		if ([self.intendedDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
		[self.intendedDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];	
		
	});

}

- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {

	if (self.pullDownToRefreshState == IRTableViewPullDownRefreshStateBegan)
	if ([self isShowingContentsAboveTheFold])
	if ([self contentOffsetAllowsFullPullToRefreshHeader]) {
			
		self.pullDownToRefreshState = IRTableViewPullDownRefreshStateActive;
		
		dispatch_async(dispatch_get_main_queue(), ^ {

			if (self.onPullDownEnd)
			self.onPullDownEnd(YES);

		});
				
	}
	
//	if (self.pullDownToRefreshState == IRTableViewPullDownRefreshStateInactive)
//	self.pullDownHeaderView.hidden = YES;

	dispatch_async(dispatch_get_main_queue(), ^ {

		if ([self.intendedDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
		[self.intendedDelegate scrollViewWillBeginDecelerating:scrollView];
	
	});

}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_current_queue(), ^ {

		[self resumeDelayedPerformQueue];
	
	});
	
	dispatch_async(dispatch_get_main_queue(), ^ {

		if ([self.intendedDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
		[self.intendedDelegate scrollViewDidEndDecelerating:scrollView];
	
	});

}





- (BOOL) isShowingContentsAboveTheFold {

	CGFloat offsetY = [super contentOffset].y;

	return (offsetY + [super contentInset].top) <= self.frame.size.height;

}

- (BOOL) contentOffsetAllowsVisiblePullToRefreshHeader {

	CGFloat offsetY = [super contentOffset].y;
	
	return (-1 * offsetY + [super contentInset].top) >= [super contentInset].top;

}

- (BOOL) contentOffsetAllowsFullPullToRefreshHeader {

	CGFloat offsetY = [super contentOffset].y;
	CGFloat additionalOffset = 0;	//	additional n pixels that the user must pull away to trigger
	
	return (-1 * offsetY - [super contentInset].top) >= (self.pullDownHeaderView.frame.size.height + additionalOffset);

}





# pragma mark -
# pragma mark Delayed Performing

NSString * const IRTableViewWillSuspendPerformingBlocksNotification = @"IRTableViewWillSuspendPerformingBlocksNotification";
NSString * const IRTableViewWillResumePerformingBlocksNotification = @"IRTableViewWillResumePerformingBlocksNotification";

- (void) suspendDelayedPerformQueue {

	if (self.delayedPerformQueueSuspended)
	return;
	
	dispatch_suspend(self.delayedPerformQueue);
	self.delayedPerformQueueSuspended = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:IRTableViewWillSuspendPerformingBlocksNotification object:self];

}

- (void) resumeDelayedPerformQueue {
	
	if (!self.delayedPerformQueueSuspended)
	return;

	dispatch_resume(self.delayedPerformQueue);
	self.delayedPerformQueueSuspended = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:IRTableViewWillResumePerformingBlocksNotification object:self];

}

- (void) performBlockOnInteractionEventsEnd:(void(^)(void))block {

	__block IRTableView *nonretainedSelf = self;

	dispatch_retain(self.delayedPerformQueue);
	[nonretainedSelf retain];

	dispatch_async(self.delayedPerformQueue, ^ {
	
		if (nonretainedSelf.delayedPerformQueueFinalizing)
		return;
		
		dispatch_async(dispatch_get_main_queue(), ^ {
		
			if (block)
			block();
			
			[nonretainedSelf autorelease];
		
		});
	
	});
	
	dispatch_release(self.delayedPerformQueue);

}





# pragma mark -
# pragma mark Conveniences

- (NSArray *) irRectsForVisibleCells {

	return [[self indexPathsForVisibleRows] irMap: ^ (NSIndexPath *indexPath, int index, BOOL *stop) {
	
		return [NSValue valueWithCGRect:[self rectForRowAtIndexPath:indexPath]];
		
	}];

}

- (void) irOffsetSafely:(CGPoint)offset animated:(BOOL)animated {

	[self setContentOffset:(CGPoint) {
	
		MAX((-1 * self.contentInset.left), MIN(self.contentSize.width, self.contentOffset.x + offset.x)), 
		MAX((-1 * self.contentInset.top), MIN(self.contentSize.height, self.contentOffset.y + offset.y)), 
	
	} animated:animated];

}

- (CGRect) irRectForRowAtIndexPathOrCGRectNull:(NSIndexPath *)anIndexPath {

//	This ought not crash, but it did, so we need a safe version
	if (NSNotFound == [[self indexPathsForVisibleRows] indexOfObject:anIndexPath])
	return CGRectNull;
	
	return [super rectForRowAtIndexPath:anIndexPath];

}





@end
