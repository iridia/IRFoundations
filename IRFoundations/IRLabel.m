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

	[attributedText release];
	[lastHighlightedRunOutline release];
	
	if (ctFramesetter)
		CFRelease(ctFramesetter);
	
	if (ctFrame)
		CFRelease(ctFrame);
	
	[super dealloc];

}

- (void) setFrame:(CGRect)frame {

	[super setFrame:frame];

	if (ctFramesetter) {
		CFRelease(ctFramesetter);
		ctFramesetter = nil;
	}
	
	if (ctFrame) {
		CFRelease(ctFrame);
		ctFrame = nil;
	}
	
	if ([self isShowingRichText])
		[self setNeedsDisplay];
	
}

- (void) setBounds:(CGRect)bounds {

	[super setBounds:bounds];
	
	if (ctFramesetter) {
		CFRelease(ctFramesetter);
		ctFramesetter = nil;
	}
	
	if (ctFrame) {
		CFRelease(ctFrame);
		ctFrame = nil;
	}
	
	if ([self isShowingRichText])
		[self setNeedsDisplay];

}

- (void) setAttributedText:(NSAttributedString *)newAttributedText {

	[self willChangeValueForKey:@"attributedText"];
	[attributedText release];
	attributedText = [newAttributedText copy];
	
	if (ctFramesetter) {
		CFRelease(ctFramesetter);
		ctFramesetter = nil;
	}
	
	if (ctFrame) {
		CFRelease(ctFrame);
		ctFrame = nil;
	}
	
	[self didChangeValueForKey:@"attributedText"];
	
	[self setNeedsDisplay];

}

- (NSAttributedString *) attributedStringForString:(NSString *)aString {

	return [self attributedStringForString:aString font:self.font color:self.textColor];

}

- (NSAttributedString *) attributedStringForString:(NSString *)aString font:(UIFont *)aFont color:(UIColor *)aColor {

	CTFontRef font = CTFontCreateWithName((CFStringRef)aFont.fontName, aFont.pointSize, NULL);
	
	//	CTLineBreakMode lineBreakMode = kCTLineBreakByTruncatingTail;
	//	CTParagraphStyleSetting paragraphStyles[] = (CTParagraphStyleSetting[]){
	//		{ kCTParagraphStyleSpecifierLineBreakMode, sizeof(lineBreakMode), &lineBreakMode },
	//	};
	//	
	//	CFIndex paragraphStylesCount = sizeof(paragraphStyles) / sizeof(CTParagraphStyleSetting);
	//	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphStyles, paragraphStylesCount);

	NSAttributedString *returnedString = [[[NSAttributedString alloc] initWithString:aString attributes:[NSDictionary dictionaryWithObjectsAndKeys:
		(id)font, kCTFontAttributeName,
	//	(id)paragraphStyle, kCTParagraphStyleAttributeName,
		(id)aColor, kCTForegroundColorAttributeName,
	nil]] autorelease];
	
	CFRelease(font);
	//	CFRelease(paragraphStyle);
	
	return returnedString;

}

- (CTFramesetterRef) ctFramesetter {

	if (!ctFramesetter)
		ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
	
	return ctFramesetter;

}

- (CTFrameRef) ctFrame {

	if (!ctFrame)
		ctFrame = CTFramesetterCreateFrame(self.ctFramesetter, (CFRange){ 0, 0 }, [UIBezierPath bezierPathWithRect:self.bounds].CGPath, nil);
	
	return ctFrame;

}

- (void) drawTextInRect:(CGRect)rect {

	if (![self isShowingRichText]) {
		[super drawTextInRect:rect];
		return;
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();	
	CGContextSaveGState(context);
	CGContextConcatCTM(context, CGAffineTransformMake(
		1, 0, 0, -1, 0, CGRectGetHeight(self.bounds)
	));
	CTFrameDraw(self.ctFrame, context);
	CGContextRestoreGState(context);

}

- (void) drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();	
	if (self.lastHighlightedRunOutline) {
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

	if ([self.gestureRecognizers containsObject:gestureRecognizer])
	if ([self.gestureRecognizers containsObject:otherGestureRecognizer])
		return YES;

	if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [self.gestureRecognizers containsObject:gestureRecognizer])
		return NO;
	
	if ([otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [self.gestureRecognizers containsObject:otherGestureRecognizer])
		return NO;
	
	if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [self.gestureRecognizers containsObject:gestureRecognizer])
		return NO;

	if ([otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && [self.gestureRecognizers containsObject:otherGestureRecognizer])
		return NO;

	return YES;

}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

	CTRunRef hitRun = [self linkRunAtPoint:[touch locationInView:self]];
	return (BOOL)(!!hitRun);

}

- (CTRunRef) linkRunAtPoint:(CGPoint)touchPoint {

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
	
	CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(self.ctFramesetter, (CFRange){ 0, 0 }, nil, (CGSize){
		CGRectGetWidth(self.bounds),
		MAXFLOAT
	}, NULL);
	
	return suggestedSize;
	
}

@end
