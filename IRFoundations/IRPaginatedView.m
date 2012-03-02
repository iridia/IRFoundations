//
//  IRPaginatedView.m
//  IRFoundations
//
//  Created by Evadne Wu on 4/17/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRPaginatedView.h"

@interface IRPaginatedView () <UIScrollViewDelegate>

- (void) irInitialize;
- (BOOL) requiresVisiblePageAtIndex:(NSUInteger)anIndex;
- (void) ensureViewAtIndexVisible:(NSUInteger)anIndex;
- (void) removeOffscreenViews;

- (CGRect) pageRectForIndex:(NSInteger)anIndex;
- (UIView *) existingViewForPageAtIndex:(NSUInteger)anIndex; // may return nil if page is not there

- (void) insertPageView:(UIView *)aView atIndex:(NSUInteger)anIndex; // swaps out existing object, calls methods if necessary
- (void) removePageView:(UIView *)aView fromIndex:(NSUInteger)anIndex; // swaps out existing object, calls methods if necessary

@property (nonatomic, readwrite, retain) UIScrollView *scrollView;

@property (nonatomic, readwrite, retain) NSMutableArray *allViews; // count equals number of pages, and contains either the UIView, or a NSNull if the view is determined to be unnecessary

@end


@implementation IRPaginatedView
@synthesize currentPage, numberOfPages;
@synthesize delegate, horizontalSpacing, scrollView, allViews;
@synthesize onPointInsideWithEvent;

- (id) initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if (!self) return nil;
	
	[self irInitialize];
	
	return self;

}

- (id) initWithCoder:(NSCoder *)aDecoder {

	self = [super initWithCoder:aDecoder];
	if (!self) return nil;
	
	[self irInitialize];
	
	return self;

}

- (void) irInitialize {

	self.scrollView = [[[UIScrollView alloc] initWithFrame:self.bounds] autorelease];
	self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.scrollView.pagingEnabled = YES;
	self.scrollView.bounces = YES;
	self.scrollView.alwaysBounceHorizontal = YES;
	self.scrollView.showsHorizontalScrollIndicator = NO;
	self.scrollView.showsVerticalScrollIndicator = NO;
	self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	self.scrollView.autoresizesSubviews = NO;
	self.scrollView.delegate = self;
	
	[self addSubview:self.scrollView];

}

- (void) reloadViews {

	for (UIView *aView in self.allViews)
	if ([aView isKindOfClass:[UIView class]])
	[aView removeFromSuperview];

	self.numberOfPages = [self.delegate numberOfViewsInPaginatedView:self];
	self.allViews = [[[NSArray irArrayByRepeatingObject:[NSNull null] count:self.numberOfPages] mutableCopy] autorelease];
	
	if ((self.currentPage + 1) <= numberOfPages)
	[self ensureViewAtIndexVisible:self.currentPage];
	
	[self setNeedsLayout];

}

- (void) setHorizontalSpacing:(CGFloat)newSpacing {

	NSParameterAssert(newSpacing > 0);

	if (horizontalSpacing == newSpacing)
	return;
	
	[self willChangeValueForKey:@"horizontalSpacing"];
	horizontalSpacing = newSpacing;
	[self didChangeValueForKey:@"horizontalSpacing"];
	
	[self setNeedsLayout];
	[self scrollToPageAtIndex:self.currentPage animated:NO];

}

- (void) setFrame:(CGRect)newFrame {

	if (CGRectEqualToRect(newFrame, self.frame))
		return;
		
	NSUInteger oldPageIndex = self.currentPage;
	
	self.scrollView.delegate = nil;
		
	[super setFrame:newFrame];
	[self setNeedsLayout];
	self.currentPage = oldPageIndex;
	self.scrollView.delegate = self;
	
	[self scrollToPageAtIndex:self.currentPage animated:NO];

}

- (CGRect) pageRectForIndex:(NSInteger)anIndex {

	if (self.bounds.size.width == 0) {
		NSLog(@"Warning: 0 page width (%s)", __PRETTY_FUNCTION__);
	}

	return (CGRect){
	
		{ self.horizontalSpacing + anIndex * self.scrollView.bounds.size.width, 0 },
		self.bounds.size
	
	};

}

- (BOOL) requiresVisiblePageAtIndex:(NSUInteger)anIndex {

	return abs(((NSInteger)anIndex - (NSInteger)self.currentPage)) <= 1;

}

- (void) ensureViewAtIndexVisible:(NSUInteger)anIndex {

	if ([self existingViewForPageAtIndex:anIndex])
		return;
	
	UIView *requestedView = [self.delegate viewForPaginatedView:self atIndex:anIndex];
	NSParameterAssert(requestedView);
	
	[self insertPageView:requestedView atIndex:anIndex];
	[self setNeedsLayout];

}

- (void) removeOffscreenViews {

	[[[self.allViews copy] autorelease] enumerateObjectsUsingBlock: ^ (id viewOrNull, NSUInteger idx, BOOL *stop) {
		
		if ([self existingViewForPageAtIndex:idx])
		if (![self requiresVisiblePageAtIndex:idx]) {
			[self removePageView:(UIView *)viewOrNull fromIndex:idx];
		}
	
	}];

}

- (void) insertPageView:(UIView *)aView atIndex:(NSUInteger)anIndex {

	NSParameterAssert(aView);
	NSParameterAssert(![self existingViewForPageAtIndex:anIndex]);
	
	UIViewController *viewController = [self.delegate viewControllerForSubviewAtIndex:anIndex inPaginatedView:self];
	[self.allViews replaceObjectAtIndex:anIndex withObject:aView];
	
	[viewController viewWillAppear:NO];
	[self.scrollView addSubview:aView];
	[self setNeedsLayout];
	[viewController viewDidAppear:NO];

}

- (void) removePageView:(UIView *)aView fromIndex:(NSUInteger)anIndex {

	NSParameterAssert(aView);
	NSParameterAssert([self existingViewForPageAtIndex:anIndex]);
	
	UIViewController *viewController = [self.delegate viewControllerForSubviewAtIndex:anIndex inPaginatedView:self];
	[self.allViews replaceObjectAtIndex:anIndex withObject:[NSNull null]];
	
	[viewController viewWillDisappear:NO];
	[aView removeFromSuperview];
	[self.scrollView setNeedsLayout];
	[viewController viewDidDisappear:NO];

}

- (UIView *) existingViewForPageAtIndex:(NSUInteger)anIndex {

	id objectAtIndex = [self.allViews objectAtIndex:anIndex];

	if ([objectAtIndex isKindOfClass:[NSNull class]] || ![objectAtIndex isKindOfClass:[UIView class]])
	return nil;

	return (UIView *)objectAtIndex;

}

- (NSUInteger) indexOfPageAtCurrentContentOffset {

	CGFloat pageWidth = [self pageRectForIndex:0].size.width;
	if (pageWidth == 0) {
		NSLog(@"Warning: page width is 0, %s returns 0", __PRETTY_FUNCTION__);
		return 0;
	}
	
	pageWidth += 2.0f * self.horizontalSpacing;
	 
	CGFloat offsetX = self.scrollView.contentOffset.x;
	
	NSInteger firstIndex = (NSInteger)floorf(offsetX / pageWidth);
	NSInteger secondIndex = firstIndex + 1;
	
	CGRect firstIntersection = CGRectIntersection([self pageRectForIndex:(NSUInteger)firstIndex], (CGRect){ self.scrollView.contentOffset, self.scrollView.frame.size });
	CGRect secondIntersection = CGRectIntersection([self pageRectForIndex:(NSUInteger)secondIndex], (CGRect){ self.scrollView.contentOffset, self.scrollView.frame.size });
	
	CGFloat firstArea = (CGRectIsEmpty(firstIntersection) || CGRectIsNull(firstIntersection) || CGRectIsInfinite(firstIntersection)) ? 0 : CGRectGetWidth(firstIntersection) * CGRectGetHeight(firstIntersection);
	CGFloat secondArea = (CGRectIsEmpty(secondIntersection) || CGRectIsNull(secondIntersection) || CGRectIsInfinite(secondIntersection)) ? 0 : CGRectGetWidth(secondIntersection) * CGRectGetHeight(secondIntersection);
	
	return (NSUInteger)((firstArea < secondArea) ? secondIndex : MAX(0, firstIndex));

}

- (void) scrollToPageAtIndex:(NSUInteger)anIndex animated:(BOOL)animate {

	CGRect pageRectInScrollView = CGRectInset([self pageRectForIndex:anIndex], -1 * self.horizontalSpacing, 0);
	
	[self.scrollView setContentOffset:pageRectInScrollView.origin animated:animate];
	[self scrollViewDidScroll:self.scrollView];

}

- (void) scrollViewDidScroll:(UIScrollView *)aScrollView {
	
	NSUInteger oldCurrentPage = currentPage;
	self.currentPage = MAX(0, MIN(self.numberOfPages - 1, [self indexOfPageAtCurrentContentOffset]));
	
//	if (![self.scrollView isTracking] && ![self.scrollView isZooming])
	if (oldCurrentPage != currentPage)
		[self setNeedsLayout];
	
}

- (void) scrollViewDidEndDragging:(UIScrollView *)aSV willDecelerate:(BOOL)decelerate {

	if (decelerate)
		return;
	
	[self scrollViewDidEndDecelerating:aSV];

}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

	if (self.numberOfPages)
	if ([self.delegate respondsToSelector:@selector(paginatedView:didShowView:atIndex:)])
		[self.delegate paginatedView:self didShowView:[self existingPageAtIndex:self.currentPage] atIndex:self.currentPage];
	
	[self removeOffscreenViews];

	[self setNeedsLayout];
	
}

- (void) layoutSubviews {

	[super layoutSubviews];
	
	@autoreleasepool {
	
		self.scrollView.delegate = nil;
		
		CGRect newFrame = CGRectInset(self.bounds, -1 * self.horizontalSpacing, 0);
		if (!CGRectEqualToRect(self.scrollView.frame, newFrame)) {
			self.scrollView.frame = newFrame;
		}
		
		CGSize newSize = (CGSize){
			CGRectGetWidth(self.scrollView.frame) * self.numberOfPages,
			CGRectGetHeight(self.scrollView.frame)
		};
		if (!CGSizeEqualToSize(self.scrollView.contentSize, newSize)) {
			self.scrollView.contentSize = newSize;
		}
		
		NSUInteger index = 0; for (index = 0; index < self.numberOfPages; index++) {
		
			if ([self requiresVisiblePageAtIndex:index])
				[self ensureViewAtIndexVisible:index];
		
			UIView *existingView = [self existingViewForPageAtIndex:index];
			
			if (!existingView)
				continue;
			
			CGRect pageRect = [self pageRectForIndex:index];
			
			if (!CGRectEqualToRect(existingView.frame, pageRect))
				existingView.frame = pageRect;
			
		}
		
		self.scrollView.delegate = self;
	
	}
	
}

- (UIView *) existingPageAtIndex:(NSUInteger)anIndex {

	if ([self.allViews count] < (anIndex + 1))
		return nil;
	
	id object = [self.allViews objectAtIndex:anIndex];
	
	if (![object isKindOfClass:[UIView class]])
		return nil;
	
	return (UIView *)object;

}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {

	BOOL answer = [super pointInside:point withEvent:event];

	if (self.onPointInsideWithEvent)
		answer = self.onPointInsideWithEvent(point, event, answer);
	
	return answer;

}

- (void) dealloc {

	[scrollView release];
	[allViews release];
	
	[onPointInsideWithEvent release];

	[super dealloc];

}


@end
