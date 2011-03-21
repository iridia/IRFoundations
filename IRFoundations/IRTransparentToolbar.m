//
//  MLTransparentToolbar.m
//  Milk
//
//  Created by Evadne Wu on 12/1/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import "IRTransparentToolbar.h"





@interface IRTransparentToolbar ()

- (void) squashStretchableItems;
- (CGFloat) reflowWithConsumedWidth:(CGFloat)inConsumedWidth;
- (void) stretchStretchableItemsWithConsumedWidth:(CGFloat)consumedWidth;

@end










@implementation IRTransparentToolbar

@synthesize delegate, leftPadding, itemPadding, rightPadding;





- (void) drawRect:(CGRect)rect {

//	Nothing

}

- (void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {

//	Nothing

}


- (void) applyTranslucentBackground {

	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	self.translucent = YES;

}

- (id) initWithFrame:(CGRect)inFrame {

	self = [super initWithFrame:inFrame];

	[self applyTranslucentBackground];

	self.leftPadding = 12;
	self.itemPadding = 10;
	self.rightPadding = 12;

	return self;

}

- (void) setLeftPadding:(float)inLeftPadding {

	if (leftPadding == inLeftPadding) return;
	leftPadding = inLeftPadding;
	[self setNeedsLayout];

}

- (void) setItemPadding:(float)inItemPadding {

	if (itemPadding == inItemPadding) return;
	itemPadding = inItemPadding;
	[self setNeedsLayout];

}

- (void) setRightPadding:(float)inRightPadding {

	if (rightPadding == inRightPadding) return;
	rightPadding = inRightPadding;
	[self setNeedsLayout];

}

- (void) setDelegate:(id <IRTransparentToolbarDelegate>)inDelegate {

	delegate = inDelegate;
	[self setNeedsLayout];

}

- (void) layoutSubviews {

	[super layoutSubviews];
	
	[self squashStretchableItems];
	
	float consumedWidth = [self reflowWithConsumedWidth:self.leftPadding];

	if (consumedWidth >= (CGRectGetWidth(self.frame) - self.rightPadding + self.itemPadding))
	return;

	[self stretchStretchableItemsWithConsumedWidth:consumedWidth];
	[self reflowWithConsumedWidth:self.leftPadding];

}

- (CGFloat) reflowWithConsumedWidth:(CGFloat)inConsumedWidth {

	__block float consumedWidth = inConsumedWidth;
	float cachedItemPadding = self.itemPadding;

	[self.subviews enumerateObjectsUsingBlock: ^ (id obj, NSUInteger idx, BOOL *stop) {
	
		UIView *item = (UIView *)obj;
		CGRect itemFrame = item.frame;
		itemFrame.origin.x = consumedWidth;
		item.frame = itemFrame;
		
		consumedWidth += CGRectGetWidth(item.frame) + cachedItemPadding;
		
	}];

	return consumedWidth;

}

- (void) squashStretchableItems {

	if (![self.delegate respondsToSelector:@selector(toolbar:shouldStretchItem:atIndex:)])
	return;
	
	for (int i = 0; i < [self.subviews count]; i++) {
	
		UIBarButtonItem *item = (UIBarButtonItem *)[self.items objectAtIndex:i];
		
		if (![self.delegate toolbar:self shouldStretchItem:item atIndex:i] && item.customView)
		continue;
		
		CGRect itemFrame = item.customView.frame;
		itemFrame.size.width = 64;
		
		item.customView.frame = itemFrame;
	
	}

}

- (void) stretchStretchableItemsWithConsumedWidth:(CGFloat)consumedWidth {

	if (![self.delegate respondsToSelector:@selector(toolbar:shouldStretchItem:atIndex:)])
	return;
	
	NSMutableArray *stretchableItems = [NSMutableArray array];
	
	for (int i = 0; i < [self.subviews count]; i++) {
	
		UIBarButtonItem *item = (UIBarButtonItem *)[self.items objectAtIndex:i];
		
		if (![self.delegate toolbar:self shouldStretchItem:item atIndex:i] && item.customView)
		continue;
		
		[stretchableItems addObject:item.customView];
	
	}
	
	if ([stretchableItems count] == 0)
	return;
	
	
	int itemCount = [stretchableItems count];
	CGFloat usableWidth = CGRectGetWidth(self.frame) - self.rightPadding - consumedWidth + self.itemPadding;
	CGFloat distributedWidth = floorf(usableWidth / itemCount);
	CGFloat remainingWidth = usableWidth - distributedWidth * itemCount;
	
	for (UIView *stretchableItemView in stretchableItems) {
		
		CGRect stretchableItemViewFrame = stretchableItemView.frame;
		stretchableItemViewFrame.size.width += distributedWidth;
		stretchableItemView.frame = stretchableItemViewFrame;
	
	}
	
	UIView *lastItemView = (UIView *)[stretchableItems objectAtIndex:([stretchableItems count] - 1)];
	CGRect lastItemViewFrame = lastItemView.frame;
	lastItemViewFrame.size.width += remainingWidth;
	lastItemView.frame = lastItemViewFrame;

}

@end




