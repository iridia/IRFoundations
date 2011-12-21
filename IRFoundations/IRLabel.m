//
//  IRLabel.m
//  Milk
//
//  Created by Evadne Wu on 2/14/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRLabel.h"
#import "CoreText+IRAdditions.h"


NSString * const kIRTextLinkAttribute = @"kIRTextLinkAttribute";
NSString * const kIRTextActiveBackgroundColorAttribute = @"kIRTextActiveBackgroundColorAttribute";

@interface IRLabel () <UIGestureRecognizerDelegate>
- (void) irCommonInit;
@property (nonatomic, readwrite, assign) CTFramesetterRef ctFramesetter;
@property (nonatomic, readwrite, assign) CTFrameRef ctFrame;
@property (nonatomic, readwrite, retain) UIBezierPath *lastHighlightedRunOutline;
- (CTRunRef) linkRunAtPoint:(CGPoint)touchPoint;

@end

@implementation IRLabel

@synthesize attributedText, ctFramesetter, ctFrame, lastHighlightedRunOutline;

+ (IRLabel *) labelWithFont:(UIFont *)aFont color:(UIColor *)aColor {

	IRLabel *returnedLabel = [[self alloc] init];
	returnedLabel.font = aFont;
	returnedLabel.textColor = aColor;
	returnedLabel.minimumFontSize = aFont.pointSize;
	returnedLabel.adjustsFontSizeToFitWidth = NO;
	
	return [returnedLabel autorelease];

}

- (id) initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if (!self)
		return nil;
	
	[self irCommonInit];
	
	return self;

}

- (void) awakeFromNib {

	[super awakeFromNib];	
	[self irCommonInit];

}

- (void) irCommonInit {

	UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)] autorelease];
	tapRecognizer.delegate = self;
	
	UILongPressGestureRecognizer *longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)] autorelease];
	longPressRecognizer.delegate = self;
	longPressRecognizer.minimumPressDuration = 0.01f;
	
	[self addGestureRecognizer:tapRecognizer];
	[self addGestureRecognizer:longPressRecognizer];
	
}

- (BOOL) isShowingRichText {

	return !!(self.attributedText);

}

- (void) dealloc {

	if (ctFramesetter)
		CFRelease(ctFramesetter);
	
	if (ctFrame)
		CFRelease(ctFrame);
	
	[attributedText release];
	[lastHighlightedRunOutline release];
	
	[super dealloc];

}

- (void) setFrame:(CGRect)frame {

	[super setFrame:frame];

	if (ctFrame) {
		CTFrameRef oldFrame = ctFrame;
		ctFrame = nil;
		CFRelease(oldFrame);
	}
	
	if (ctFramesetter) {
		CTFramesetterRef oldFramesetter = ctFramesetter;
		ctFramesetter = nil;
		CFRelease(oldFramesetter);
	}
	
	if ([self isShowingRichText])
		[self setNeedsDisplay];
	
}

- (void) setBounds:(CGRect)bounds {

	[super setBounds:bounds];
	
	if (ctFrame) {
		CTFrameRef oldFrame = ctFrame;
		ctFrame = nil;
		CFRelease(oldFrame);
	}
	
	if (ctFramesetter) {
		CTFramesetterRef oldFramesetter = ctFramesetter;
		ctFramesetter = nil;
		CFRelease(oldFramesetter);
	}
	
	if ([self isShowingRichText])
		[self setNeedsDisplay];

}

- (void) setAttributedText:(NSAttributedString *)newAttributedText {

	if (attributedText == newAttributedText)
		return;
	
	[self willChangeValueForKey:@"attributedText"];
	
	if (ctFrame) {
		CTFrameRef oldFrame = ctFrame;
		ctFrame = nil;
		CFRelease(oldFrame);
	}
	
	if (ctFramesetter) {
		CTFramesetterRef oldFramesetter = ctFramesetter;
		ctFramesetter = nil;
		CFRelease(oldFramesetter);
	}
	
	[attributedText release];
	attributedText = [newAttributedText copy];
	
	[self didChangeValueForKey:@"attributedText"];
	[self setNeedsDisplay];

}

- (NSAttributedString *) attributedStringForString:(NSString *)aString {

	return [self attributedStringForString:aString font:self.font color:self.textColor];

}

- (NSAttributedString *) attributedStringForString:(NSString *)aString font:(UIFont *)aFont color:(UIColor *)aColor {

	if (!aString)
		return nil;

	CTFontRef font = CTFontCreateWithName((CFStringRef)aFont.fontName, aFont.pointSize, NULL);
	
	NSAttributedString *returnedString = [[[NSAttributedString alloc] initWithString:aString attributes:[NSDictionary dictionaryWithObjectsAndKeys:
		(id)font, kCTFontAttributeName,
		(id)(aColor ? aColor.CGColor : [UIColor blackColor].CGColor), kCTForegroundColorAttributeName,
	nil]] autorelease];
	
	CFRelease(font);
	
	return returnedString;

}

- (CTFramesetterRef) ctFramesetter {

	NSParameterAssert([NSThread isMainThread]);

	if (ctFramesetter)
		return ctFramesetter;
	
	@synchronized (self) {
		if (attributedText)
			ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedText);
	}
	
	return ctFramesetter;

}

- (CTFrameRef) ctFrame {

	//	Note: we might have label bounds that are shorter than even one line of text, so in that case constrain the size to at least the height of the first row to avoid bugs where the label will show nothing

	if (ctFrame)
		return ctFrame;
	
	CGRect frameRect = (CGRect){
		0,
		-4,
		self.bounds.size.width,
		self.bounds.size.height + 4
	};
	
	CFAttributedStringRef currentAttributedString = (CFAttributedStringRef)self.attributedText;
	if (!currentAttributedString)
		return;
	
	CFRetain(currentAttributedString);
	
	CTFramesetterRef currentFramesetter = self.ctFramesetter;
	CFRetain(currentFramesetter);
	
	CFRange actualRange = (CFRange){ 0, 0 };
	CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(currentFramesetter, (CFRange){ 0, 0 }, nil, (CGSize){
		frameRect.size.width,
		frameRect.size.height
	}, &actualRange);
	
	@synchronized (self) {
	
		ctFrame = CTFramesetterCreateFrame(currentFramesetter, actualRange, [UIBezierPath bezierPathWithRect:frameRect].CGPath, nil);
	
	}

	CFRelease(currentAttributedString);
	CFRelease(currentFramesetter);
	
	return ctFrame;

}

- (void) drawTextInRect:(CGRect)rect {

	if (![self isShowingRichText]) {
		[super drawTextInRect:rect];
		return;
	}
	
	CTFrameRef usedFrame = self.ctFrame;
	if (!usedFrame)
		return;
	
	CFRetain(usedFrame);
	CGContextRef context = UIGraphicsGetCurrentContext();	
	CGContextSaveGState(context);
	CGContextConcatCTM(context, CGAffineTransformMake(
		1, 0, 0, -1, 0, CGRectGetHeight(self.bounds)
	));
	CTFrameDraw(usedFrame, context);
	CGContextRestoreGState(context);
	CFRelease(usedFrame);

}

- (void) drawRect:(CGRect)rect {
	
	if (self.lastHighlightedRunOutline) {
		CGContextRef context = UIGraphicsGetCurrentContext();	
		CGContextSaveGState(context);
		CGContextConcatCTM(context, CGAffineTransformMake(
			1, 0, 0, -1, 0, CGRectGetHeight(self.bounds)
		));
		
		CGContextAddPath(context, self.lastHighlightedRunOutline.CGPath);
		CGContextSetFillColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:0.15f].CGColor);
		CGContextFillPath(context);
		CGContextRestoreGState(context);	
	}

	[super drawRect:rect];
	
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

	return ![otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];

}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

	CTRunRef hitRun = [self linkRunAtPoint:[touch locationInView:self]];
	return (BOOL)(!!hitRun);

}

- (CTRunRef) linkRunAtPoint:(CGPoint)touchPoint {

	if (!self.attributedText)
		return nil;

	touchPoint.y = CGRectGetHeight(self.bounds) - touchPoint.y;
	
	CTRunRef hitRun = irCTFrameFindRunAtPoint(self.ctFrame, touchPoint, 2.0, nil, [NSDictionary dictionaryWithObjectsAndKeys:
		[[^ (id key, id value) {
			return !!value;
		} copy] autorelease], kIRTextLinkAttribute,
	nil]);
	
	return hitRun;

}

- (void) handleTap:(UITapGestureRecognizer *)aTapRecognizer {

	CTRunRef hitRun = [self linkRunAtPoint:[aTapRecognizer locationInView:self]];
	
	NSURL *link = [(NSDictionary *)CTRunGetAttributes(hitRun) objectForKey:kIRTextLinkAttribute];
	
	if ([link isKindOfClass:[NSURL class]])
		[[UIApplication sharedApplication] openURL:link];

}

- (void) handleLongPress:(UILongPressGestureRecognizer *)aLongPressRecognizer {

	CTRunRef hitRun = [self linkRunAtPoint:[aLongPressRecognizer locationInView:self]];
		
	switch (aLongPressRecognizer.state) {
		case UIGestureRecognizerStatePossible: {
			break;
		}
    case UIGestureRecognizerStateBegan:
    case UIGestureRecognizerStateChanged: {
			
			if (hitRun) {
				
				self.lastHighlightedRunOutline = irCTFrameGetRunOutline(self.ctFrame, irCTFrameFindNeighborRuns(self.ctFrame, hitRun, [NSDictionary dictionaryWithObjectsAndKeys:
					[[^ (id key, id value) { return !!value; } copy] autorelease], kIRTextLinkAttribute,
				nil]), UIEdgeInsetsZero, 4.0f, YES, YES, NO);
				
				[self setNeedsDisplay];
				
			} else {
			
				self.lastHighlightedRunOutline = nil;
				
				[self setNeedsDisplay];
			
			}
			
			break;
		}
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateFailed: {
		
			self.lastHighlightedRunOutline = nil;
			
			[self setNeedsDisplay];
		
			break;
			
		}
	};

}

- (CGSize) sizeThatFits:(CGSize)size {
	
	if (![self isShowingRichText])
		return [super sizeThatFits:size];
		
	if (![self.attributedText length])
		return CGSizeZero;
	
	CTFramesetterRef currentFramesetter = self.ctFramesetter;
	if (!currentFramesetter)
		return CGSizeZero;
	
	CFRetain(currentFramesetter);
	
	CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(currentFramesetter, (CFRange){ 0, 0 }, nil, (CGSize){
		size.width, //CGRectGetWidth(self.bounds),
		MAXFLOAT
	}, NULL);
	
	CFRelease(currentFramesetter);
	
	return suggestedSize;
	
}

@end


@implementation UILabel (IRAdditions)

- (void) irPlaceBehindLabel:(UILabel *)anotherLabel {

	[self irPlaceBehindLabel:anotherLabel withEdgeInsets:UIEdgeInsetsZero];

}

- (void) irPlaceBehindLabel:(UILabel *)anotherLabel withEdgeInsets:(UIEdgeInsets)edgeInsets {

	NSParameterAssert(anotherLabel.superview == self.superview);
	
	//	Not really useful:
	//	CGRect initialFrame = [anotherLabel convertRect:[anotherLabel textRectForBounds:anotherLabel.bounds limitedToNumberOfLines:anotherLabel.numberOfLines] toView:anotherLabel.superview];
	
	CGRect initialFrame = anotherLabel.frame;
	
	if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, edgeInsets))
		initialFrame = UIEdgeInsetsInsetRect(initialFrame, edgeInsets);
	
	self.frame = (CGRect){
		(CGPoint){
			CGRectGetMaxX(initialFrame),
			roundf(CGRectGetMaxY(initialFrame) - CGRectGetHeight(self.frame) + anotherLabel.font.descender - self.font.descender)
		},
		self.frame.size
	};

}

@end
