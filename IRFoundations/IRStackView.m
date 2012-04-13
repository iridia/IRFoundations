//
//  WAStackView.m
//  wammer
//
//  Created by Evadne Wu on 12/21/11.
//  Copyright (c) 2011 Waveface. All rights reserved.
//

#import "IRStackView.h"


@interface IRStackView () <UIGestureRecognizerDelegate>

- (void) irInit;

@property (nonatomic, readonly, retain) NSArray *stackElements;
- (NSMutableArray *) mutableStackElements; 
- (CGSize) sizeThatFitsElement:(UIView *)anElement;

@property (nonatomic, readwrite, assign) NSInteger stackElementLayoutPostponingCount;

@end


@implementation IRStackView
@synthesize stackElements;
@dynamic delegate;
@synthesize stackElementLayoutPostponingCount;
@synthesize onDidLayoutSubviews;

- (id) initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if (!self)
		return nil;
	
	[self irInit];
	
	return self;

}

- (void) awakeFromNib {

	[super awakeFromNib];
	
	[self irInit];

}

- (void) setFrame:(CGRect)newFrame {

	if (CGRectEqualToRect(newFrame, self.frame))
		return;
	
	[super setFrame:newFrame];

}

- (void) setBounds:(CGRect)newBounds {

	if (CGRectEqualToRect(newBounds, self.bounds))
		return;
	
	[super setBounds:newBounds];

}

- (void) setCenter:(CGPoint)newCenter {

	if (CGPointEqualToPoint(newCenter, self.center))
		return;
	
	[super setCenter:newCenter];

}

- (void) irInit {

	stackElements = [NSArray array];
	
	//	self.bounces = YES;
	//	self.alwaysBounceHorizontal = NO;
	//	self.alwaysBounceVertical = NO;

}

- (void) setStackElements:(NSArray *)newStackElements {

	if (stackElements == newStackElements)
		return;
	
	[self willChangeValueForKey:@"stackElements"];
	stackElements = newStackElements;
	[self didChangeValueForKey:@"stackElements"];
	
	[self setNeedsLayout];

}

- (NSMutableArray *) mutableStackElements {

	return [self mutableArrayValueForKey:@"stackElements"];

}

- (void) addStackElements:(NSSet *)objects {

	[[self mutableStackElements] addObjectsFromArray:[objects allObjects]];
	[self setNeedsLayout];

}

- (void) addStackElementsObject:(UIView *)object {

	[[self mutableStackElements] addObject:object];
	[self setNeedsLayout];

}

- (void) removeStackElements:(NSSet *)objects {

	for (UIView *aView in [objects allObjects])
		[aView removeFromSuperview];
	
	[[self mutableStackElements] removeObjectsInArray:[objects allObjects]];
	
	[self setNeedsLayout];

}

- (void) removeStackElementsAtIndexes:(NSIndexSet *)indexes {

	NSArray *removedObjects = [[self mutableStackElements] objectsAtIndexes:indexes];
	for (UIView *anObject in removedObjects)
		[anObject removeFromSuperview];

	[[self mutableStackElements] removeObjectsAtIndexes:indexes];
	[self setNeedsLayout];

}

- (void) removeStackElementsObject:(UIView *)object {

	[object removeFromSuperview];

	[[self mutableStackElements] removeObject:object];
	[self setNeedsLayout];

}

- (void) layoutSubviews {

	[super layoutSubviews];
	
	if (![self isPostponingStackElementLayout]) {
	
		__block CGPoint nextOffset = CGPointZero;
		__block CGRect contentRect = CGRectZero;
		
		CGFloat usableHeight = CGRectGetHeight(self.bounds);
		
		NSMutableDictionary *elementsToFrames = (__bridge_transfer NSMutableDictionary *)CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		CGRect (^desiredFrameForElement)(UIView *) = ^ (UIView *element) {
			NSValue *rectValue = (__bridge NSValue *)(CFDictionaryGetValue((__bridge CFMutableDictionaryRef)elementsToFrames, (__bridge const void *)(element)));
			return [rectValue CGRectValue];
		};
		void (^setDesiredFrameForElement)(UIView *, CGRect) = ^ (UIView *element, CGRect frame) {
			CFDictionarySetValue((__bridge CFMutableDictionaryRef)elementsToFrames, (__bridge const void *)(element), (__bridge const void *)([NSValue valueWithCGRect:frame]));
		};
		
		for (UIView *anElement in self.stackElements) {
		
			setDesiredFrameForElement(anElement, anElement.frame);
								
			if (anElement.superview != self)
				[self addSubview:anElement];
			
			CGSize fitSize = [self sizeThatFitsElement:anElement];
			
			CGRect fitFrame = (CGRect){
				nextOffset,
				fitSize
			};

			if (!CGRectEqualToRect(desiredFrameForElement(anElement), fitFrame))
				setDesiredFrameForElement(anElement, fitFrame);
			
			contentRect = CGRectIntersection(CGRectInfinite, CGRectUnion(contentRect, fitFrame));
			
			nextOffset = (CGPoint){
				0,
				CGRectGetMaxY(fitFrame)
			};
			
			[anElement.superview bringSubviewToFront:anElement];
		
		}
		
		if (CGRectGetHeight(contentRect) < usableHeight) {
		
			//	Find stretchable stuff
			
			__block CGFloat additionalOffset = 0;
			__block CGFloat availableOffset = usableHeight - CGRectGetHeight(contentRect);
			
			NSMutableArray *stretchableElements = [NSMutableArray array];
			
			for (UIView *anElement in self.stackElements)
				if ([self.delegate stackView:self shouldStretchElement:anElement])
					[stretchableElements addObject:anElement];
			
			if ([stretchableElements count]) {
			
				[self.stackElements enumerateObjectsUsingBlock: ^ (UIView *anElement, NSUInteger idx, BOOL *stop) {
				
					CGRect startingElementFrame = CGRectOffset(desiredFrameForElement(anElement), 0, additionalOffset);
					
					if (![stretchableElements containsObject:anElement])
						return;
					
					CGFloat consumedHeight = ([stretchableElements lastObject] == anElement) ? availableOffset : roundf(availableOffset / [stretchableElements count]);
					CGRect newElementFrame = startingElementFrame;
					newElementFrame.size.height += consumedHeight;
					setDesiredFrameForElement(anElement, newElementFrame);
					
					availableOffset -= consumedHeight;
					additionalOffset += consumedHeight;
					
				}];
			
			}
			
			contentRect.size.height = usableHeight;
			
		}
		
		[self.stackElements enumerateObjectsUsingBlock: ^ (UIView *anElement, NSUInteger idx, BOOL *stop) {
		
			CGRect desiredFrame = desiredFrameForElement(anElement);
			
			if (!CGRectEqualToRect(anElement.frame, desiredFrame)) {
				anElement.frame = desiredFrame;
			}
			
		}];
		
		if (!CGSizeEqualToSize(self.contentSize, contentRect.size))
			self.contentSize = contentRect.size;
	
	}
	
	if (self.onDidLayoutSubviews)
		self.onDidLayoutSubviews();

}

- (CGSize) sizeThatFitsElement:(UIView *)anElement {

	NSParameterAssert([self.stackElements containsObject:anElement]);
	NSParameterAssert(self.delegate);
	
	CGSize bestSize = [self.delegate sizeThatFitsElement:anElement inStackView:self];
	
	return bestSize;

}

- (void) beginPostponingStackElementLayout {

	self.stackElementLayoutPostponingCount++;

}

- (void) endPostponingStackElementLayout {

	self.stackElementLayoutPostponingCount--;

}

- (BOOL) isPostponingStackElementLayout {

	return !!self.stackElementLayoutPostponingCount;

}

@end
