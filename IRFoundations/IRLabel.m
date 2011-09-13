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
@property (nonatomic, readwrite, retain) UIGestureRecognizer *tapRecognizer;

- (CTRunRef) linkRunAtPoint:(CGPoint)touchPoint;

@end

@implementation IRLabel

@synthesize attributedText, ctFramesetter, ctFrame, tapRecognizer;

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

	self.tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)] autorelease];
	self.tapRecognizer.delegate = self;
	[self addGestureRecognizer:self.tapRecognizer];

}

- (BOOL) isShowingRichText {

	return !!(self.attributedText);

}

- (void) dealloc {

	[tapRecognizer release];
	[attributedText release];
	
	if (ctFramesetter)
		CFRelease(ctFramesetter);
	
	if (ctFrame)
		CFRelease(ctFrame);
	
	[super dealloc];

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

	CTFontRef font = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, NULL);

	NSAttributedString *returnedString = [[[NSAttributedString alloc] initWithString:aString attributes:[NSDictionary dictionaryWithObjectsAndKeys:
		(id)font, kCTFontAttributeName,
	nil]] autorelease];
	
	CFRelease(font);
	
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

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

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

- (void) handleTap:(UITapGestureRecognizer *)aLongPressRecognizer {

	CTRunRef hitRun = [self linkRunAtPoint:[aLongPressRecognizer locationInView:self]];
	
	NSURL *link = [(NSDictionary *)CTRunGetAttributes(hitRun) objectForKey:kIRTextLinkAttribute];
	
	if ([link isKindOfClass:[NSURL class]])
		[[UIApplication sharedApplication] openURL:link];

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
