//
//  IRBarButtonItem.m
//  IRFoundations
//
//  Created by Evadne Wu on 3/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRBarButtonItem.h"
#import "IRLifetimeHelper.h"


@implementation IRBarButtonItem

@synthesize block;

- (void) dealloc {

	[block release];
	
	[super dealloc];

}

+ (id) itemWithCustomView:(UIView *)aView {

	return [[[self alloc] initWithCustomView:aView] autorelease];

}

+ (id) itemWithTitle:(NSString *)aTitle action:(void(^)(void))aBlock {

	IRBarButtonItem *returnedItem = [[[self alloc] initWithTitle:aTitle style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
	returnedItem.target = returnedItem;
	returnedItem.action = @selector(handleCustomButtonAction:);
	returnedItem.block = aBlock;
	
	return returnedItem;

}

+ (id) itemWithSystemItem:(UIBarButtonSystemItem)aSystemItem wiredAction:(void(^)(IRBarButtonItem *senderItem))aBlock {

	IRBarButtonItem *returnedItem = [[self alloc] initWithBarButtonSystemItem:aSystemItem target:nil action:nil];
	if (!returnedItem) return nil;
	
	returnedItem.target = returnedItem;
	returnedItem.action = @selector(handleCustomButtonAction:);
	
	returnedItem.block = ^ { aBlock(returnedItem); };
	
	return returnedItem; 

}

+ (id) itemWithButton:(UIButton *)aButton wiredAction:(void(^)(UIButton *senderButton, IRBarButtonItem *senderItem))aBlock {

	__block IRBarButtonItem *returnedItem = [self itemWithCustomView:aButton];
	if (!returnedItem) return nil;
	
	if (aBlock) {
		returnedItem.block = ^ { aBlock(aButton, returnedItem); };
	}
	
	[aButton addTarget:returnedItem action:@selector(handleCustomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	
	return returnedItem;

}

+ (id) itemWithCustomImage:(UIImage *)aFullImage highlightedImage:(UIImage *)aHighlightedImage {

	UIButton *returnedButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[returnedButton setImage:aFullImage forState:UIControlStateNormal];
	
	if (aHighlightedImage)
		[returnedButton setImage:aHighlightedImage forState:UIControlStateHighlighted];
	
	[returnedButton sizeToFit];
	
	return [self itemWithButton:returnedButton wiredAction:nil];

}

+ (id) itemWithCustomImage:(UIImage *)aFullImage landscapePhoneImage:(UIImage *)landscapePhoneImage highlightedImage:(UIImage *)aHighlightedImage highlightedLandscapePhoneImage:(UIImage *)highlightedLandscapePhoneImage {

	__block UIButton *returnedButton = [UIButton buttonWithType:UIButtonTypeCustom];
	returnedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	returnedButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	IRBarButtonItem *returnedItem = [self itemWithButton:returnedButton wiredAction:nil];
	
	BOOL (^isPhone)(void) = ^ {
		
		return (BOOL)([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone);
		
	};
	
	void (^updateButtonImage)(UIInterfaceOrientation) = [[^ (UIInterfaceOrientation anOrientation) {
	
		BOOL landscapePhone = (isPhone()) && UIInterfaceOrientationIsLandscape(anOrientation);
		
		UIImage *image = landscapePhone ? (landscapePhoneImage ? landscapePhoneImage : aFullImage) : aFullImage;
		UIImage *highlightedImage = landscapePhone ? (highlightedLandscapePhoneImage ? highlightedLandscapePhoneImage : aHighlightedImage) : aHighlightedImage;
				
		[returnedButton setImage:image forState:UIControlStateNormal];
		
		if (highlightedImage)
			[returnedButton setImage:highlightedImage forState:UIControlStateHighlighted];
		
		[returnedButton sizeToFit];
		
	} copy] autorelease];
	
	if (isPhone()) {
	
		__block id notificationObject = [[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:nil usingBlock: ^ (NSNotification *note) {
		
			updateButtonImage([UIApplication sharedApplication].statusBarOrientation);
			
		}] retain];
		
		[returnedItem irPerformOnDeallocation:^{
			
			[[NSNotificationCenter defaultCenter] removeObserver:notificationObject];
			[notificationObject release];
			
		}];
	
	}
	
	updateButtonImage([UIApplication sharedApplication].statusBarOrientation);
	
	return returnedItem;

}

+ (id) backItemWithTitle:(NSString *)aTitle tintColor:(UIColor *)aColor {

	UIImage *image = [[self class] backButtonImageWithTitle:aTitle font:nil backgroundColor:nil gradientColors:nil innerShadow:nil border:nil shadow:nil];
	UIImage *highlightedImage = [[self class] backButtonImageWithTitle:aTitle font:nil backgroundColor:nil gradientColors:[NSArray arrayWithObjects:
			(id)[UIColor colorWithRed:1 green:1 blue:1 alpha:.75].CGColor,
			(id)[UIColor colorWithRed:.4 green:.4 blue:.4 alpha:.75].CGColor,
		nil] innerShadow:nil border:nil shadow:nil];
	
	return [self itemWithCustomImage:image highlightedImage:highlightedImage];

}

+ (id) itemWithTitle:(NSString *)aTitle tintColor:(UIColor *)aColor {

	UIButton *returnedButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[returnedButton setImage:[[self class] buttonImageForStyle:IRBarButtonItemStyleBordered withTitle:aTitle font:nil backgroundColor:nil gradientColors:nil innerShadow:nil border:nil shadow:nil] forState:UIControlStateNormal];
	[returnedButton setImage:[[self class] buttonImageForStyle:IRBarButtonItemStyleBordered withTitle:aTitle font:nil backgroundColor:nil gradientColors:[NSArray arrayWithObjects:
		(id)[UIColor colorWithRed:1 green:1 blue:1 alpha:.75].CGColor,
		(id)[UIColor colorWithRed:.4 green:.4 blue:.4 alpha:.75].CGColor,
	nil] innerShadow:nil border:nil shadow:nil] forState:UIControlStateHighlighted];
	[returnedButton sizeToFit];
	
	return [self itemWithButton:returnedButton wiredAction:nil];

}

- (IBAction) handleCustomButtonAction:(id)sender {

	if (self.block)
	self.block();

}

- (void) setBlock:(void (^)())newBlock {

	if (newBlock == self.block)
	return;
	
	[self willChangeValueForKey:@"block"];
	
	[block release];
	block = [newBlock copy];
	
	[self didChangeValueForKey:@"block"];
	
	if (newBlock) {
		self.target = self;
		self.action = @selector(handleCustomButtonAction:);
	}
	
}





+ (UIImage *) backButtonImageWithTitle:(NSString *)aTitle font:(UIFont *)fontOrNil backgroundColor:(UIColor *)backgroundColorOrNil gradientColors:(NSArray *)backgroundGradientColorsOrNil innerShadow:(IRShadow *)innerShadowOrNil border:(IRBorder *)borderOrNil shadow:(IRShadow *)shadowOrNil {
	
	return [self buttonImageForStyle:IRBarButtonItemStyleBack withTitle:aTitle font:fontOrNil backgroundColor:backgroundColorOrNil gradientColors:backgroundGradientColorsOrNil innerShadow:innerShadowOrNil border:borderOrNil shadow:shadowOrNil];

}

+ (UIImage *) buttonImageForStyle:(IRBarButtonItemStyle)aStyle withTitle:(NSString *)aTitle font:(UIFont *)fontOrNil backgroundColor:(UIColor *)backgroundColorOrNil gradientColors:(NSArray *)backgroundGradientColorsOrNil innerShadow:(IRShadow *)innerShadowOrNil border:(IRBorder *)borderOrNil shadow:(IRShadow *)shadowOrNil {

	return [self buttonImageForStyle:aStyle withTitle:aTitle font:fontOrNil color:nil shadow:nil backgroundColor:backgroundColorOrNil gradientColors:backgroundGradientColorsOrNil innerShadow:innerShadowOrNil border:borderOrNil shadow:shadowOrNil];

}

+ (UIImage *) buttonImageForStyle:(IRBarButtonItemStyle)aStyle withTitle:(NSString *)aTitle font:(UIFont *)fontOrNil color:(UIColor *)titleColor shadow:(IRShadow *)titleShadow backgroundColor:(UIColor *)backgroundColorOrNil gradientColors:(NSArray *)backgroundGradientColorsOrNil innerShadow:(IRShadow *)innerShadowOrNil border:(IRBorder *)borderOrNil shadow:(IRShadow *)shadowOrNil {

	return [self buttonImageForStyle:aStyle withImage:nil title:aTitle font:fontOrNil color:titleColor shadow:titleShadow backgroundColor:backgroundColorOrNil gradientColors:backgroundGradientColorsOrNil innerShadow:innerShadowOrNil border:borderOrNil shadow:shadowOrNil];

}

+ (UIImage *) buttonImageForStyle:(IRBarButtonItemStyle)aStyle withImage:(UIImage *)anImage title:(NSString *)aTitle font:(UIFont *)fontOrNil color:(UIColor *)titleColor shadow:(IRShadow *)titleShadow backgroundColor:(UIColor *)backgroundColorOrNil gradientColors:(NSArray *)backgroundGradientColorsOrNil innerShadow:(IRShadow *)innerShadowOrNil border:(IRBorder *)borderOrNil shadow:(IRShadow *)shadowOrNil {

	NSString *usingTitle = aTitle ? aTitle : @"";
	UIFont *usingFont = fontOrNil ? fontOrNil : [UIFont boldSystemFontOfSize:12.0f];
	UIColor *buttonBackgroundColor = backgroundColorOrNil ? backgroundColorOrNil : [UIColor colorWithWhite:0.35f alpha:1];
	IRShadow *buttonShadow = shadowOrNil ? shadowOrNil : [IRShadow shadowWithColor:[UIColor colorWithWhite:1 alpha:0.5] offset:(CGSize){ 0, 1 } spread:0.5];
	NSArray *buttonGradientColors = backgroundGradientColorsOrNil ? backgroundGradientColorsOrNil : [NSArray arrayWithObjects:
		
		(id)[UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor,
		(id)[UIColor colorWithRed:.4 green:.4 blue:.4 alpha:1].CGColor,
	
	nil];
	
	UIColor *usingTitleColor = titleColor ? titleColor : [UIColor colorWithWhite:0.2 alpha:1];
	IRShadow *usingTitleShadow = titleShadow ? titleShadow : [IRShadow shadowWithColor:[UIColor colorWithWhite:1 alpha:0.65f] offset:(CGSize){ 0, 1 } spread:0];
	
	IRShadow *buttonInnerShadow = innerShadowOrNil ? innerShadowOrNil : [IRShadow shadowWithColor:[UIColor colorWithWhite:0 alpha:0.5] offset:(CGSize){ 0, 1 } spread:2];
	IRBorder *buttonBorder = borderOrNil ? borderOrNil : [IRBorder borderForEdge:IREdgeNone withType:IRBorderTypeInset width:1.0 color:[UIColor colorWithWhite:0.35 alpha:1]];
	
	UIEdgeInsets insets = UIEdgeInsetsZero;
	CGPoint contentOffset = CGPointZero;
	
	CGSize titleSize = [usingTitle sizeWithFont:usingFont];
	CGSize imageSize = [anImage size];
	
	CGFloat itemSpacing = (titleSize.width && imageSize.width) ? 4 : 0;
	
	CGSize contentSize = (CGSize){
		imageSize.width + itemSpacing + titleSize.width,
		MAX(imageSize.height, titleSize.height)
	};
	
	CGPoint imageOffset = (CGPoint){
		0,
		roundf(0.5f * (contentSize.height - imageSize.height))
	};
	CGPoint titleOffset = (CGPoint){
		imageSize.width + itemSpacing,
		roundf(0.5f * (contentSize.height - titleSize.height))
	};
	
	CGSize finalSize = (CGSize){ 0, 0 };
	
	UIBezierPath *bezierPath = nil;
	
	switch (aStyle) {
	
		case IRBarButtonItemStyleBack:
		case IRBarButtonItemStyleBackLandscapePhone: {
		
			BOOL const isLandscapePhone = (aStyle == IRBarButtonItemStyleBackLandscapePhone);
			
			CGFloat const buttonHeight = isLandscapePhone ? 25.0 : 29.0;
			CGFloat const cornerRadius = 6;
			CGFloat const slopeSize = 3;
			
			insets = isLandscapePhone ? (UIEdgeInsets){ 0, 10, 0, 2 } : (UIEdgeInsets){ 0, 12, 0, 2 };
			finalSize = (CGSize){ contentSize.width + 16 + 8, 44.0f };
			bezierPath = [UIBezierPath bezierPath];
			contentOffset = (CGPoint){ -2, 0 };
			
			[bezierPath moveToPoint:CGPointZero];		
			[bezierPath addLineToPoint:(CGPoint){ insets.left - slopeSize, -1 * (0.5 * buttonHeight - slopeSize) }];		
			[bezierPath addQuadCurveToPoint:(CGPoint){ insets.left + slopeSize, -1 * (0.5 * buttonHeight) }
												 controlPoint:(CGPoint){ insets.left, -1 * (0.5 * buttonHeight) }];
			[bezierPath addLineToPoint:(CGPoint){ finalSize.width - insets.right - cornerRadius, -1 * (0.5 * buttonHeight) }];
			[bezierPath addQuadCurveToPoint:(CGPoint){ finalSize.width - insets.right, -1 * (0.5 * buttonHeight - cornerRadius) }
												 controlPoint:(CGPoint){ finalSize.width - insets.right, -1 * (0.5 * buttonHeight) }];
			[bezierPath addLineToPoint:(CGPoint){ finalSize.width - insets.right, 1 * (0.5 * buttonHeight - cornerRadius) }];
			[bezierPath addQuadCurveToPoint:(CGPoint){ finalSize.width - insets.right - cornerRadius, 1 * (0.5 * buttonHeight) }
												 controlPoint:(CGPoint){ finalSize.width - insets.right, 1 * (0.5 * buttonHeight) }];
			[bezierPath addLineToPoint:(CGPoint){ insets.left + slopeSize, 1 * (0.5 * buttonHeight) }];
			[bezierPath addQuadCurveToPoint:(CGPoint){ insets.left - slopeSize, 1 * (0.5 * buttonHeight - slopeSize) }
												 controlPoint:(CGPoint){ insets.left, 1 * (0.5 * buttonHeight) }];
			[bezierPath addLineToPoint:CGPointZero];
			[bezierPath applyTransform:CGAffineTransformMakeTranslation(0, -0.5 + 0.5 * finalSize.height)];
			
			break;
			
		};
		
		case IRBarButtonItemStyleBordered:
		case IRBarButtonItemStyleBorderedLandscapePhone: {
		
			BOOL const isLandscapePhone = (aStyle == IRBarButtonItemStyleBorderedLandscapePhone);
			
			CGFloat const buttonHeight = isLandscapePhone ? 24.0 : 29.0;
			CGFloat const cornerRadius = 6;
			insets = UIEdgeInsetsZero;
			finalSize = (CGSize){ contentSize.width + 20, 44.0f };
			bezierPath = [UIBezierPath bezierPathWithRoundedRect:(CGRect){
				(CGPoint){
					insets.left,
					floorf(0.5 * (finalSize.height - buttonHeight))
				},
				(CGSize){
					finalSize.width - insets.left - insets.right,
					buttonHeight
				}
			} cornerRadius:cornerRadius];
			
			break;
		
		};
		
		default:
			break;
	
	}
	
	UIGraphicsBeginImageContextWithOptions(finalSize, NO, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (buttonShadow) {
	
		BOOL const knockoutShadow = YES;
		
		if (knockoutShadow) {
	
			CGContextSaveGState(context);
			
			CGContextSetShadowWithColor(context, buttonShadow.offset, buttonShadow.spread, buttonShadow.color.CGColor);
			
			CGContextAddPath(context, bezierPath.CGPath);
			CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
			CGContextFillPath(context);
			
			CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
			
			CGContextSetBlendMode(context, kCGBlendModeClear); // first clean underlying stuff
			CGContextAddPath(context, bezierPath.CGPath);
			CGContextFillPath(context);		
			
			CGContextRestoreGState(context);
		
		} else {
		
			CGContextSetShadowWithColor(context, buttonShadow.offset, buttonShadow.spread, buttonShadow.color.CGColor);
		
		}
	
	}
	
	CGContextBeginTransparencyLayer(context, NULL);
	
	if (buttonBackgroundColor) {
	
		CGContextSaveGState(context);
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextSetFillColorWithColor(context, buttonBackgroundColor.CGColor);
		CGContextFillPath(context);
		CGContextRestoreGState(context);
	
	}
	
	if (buttonGradientColors) {
	
		CGContextSaveGState(context);
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextClip(context);
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGGradientRef topGradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)buttonGradientColors, NULL);
		CGColorSpaceRelease(colorSpace);
		CGContextDrawLinearGradient(context, topGradient, CGPointZero, (CGPoint){ 0, floorf(1 * finalSize.height) }, 0);
		CGGradientRelease(topGradient);

		CGContextRestoreGState(context);
	
	}
	
	if (buttonInnerShadow) {
	
		CGContextSaveGState(context);
		
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextClip(context);
		CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
		CGContextSetLineWidth(context, buttonInnerShadow.spread);
		
		float_t const largeDistance = 1024.0;
		
		CGContextTranslateCTM(context, 0, largeDistance);
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextTranslateCTM(context, 0, -largeDistance);
		
		CGContextSetShadowWithColor(context, (CGSize){
			buttonInnerShadow.offset.width,
			buttonInnerShadow.offset.height - largeDistance
		}, buttonInnerShadow.spread, buttonInnerShadow.color.CGColor);
		
		CGContextStrokePath(context);
		
		CGContextRestoreGState(context);
	
	}
	
	if (buttonBorder) {
	
		NSParameterAssert(buttonBorder.type == IRBorderTypeInset);
		
		CGContextSaveGState(context);
		CGContextAddPath(context, bezierPath.CGPath);
		
		CGContextClip(context);
		CGContextSetStrokeColorWithColor(context, buttonBorder.color.CGColor);
		CGContextSetLineWidth(context, buttonBorder.width * 2);
		
//		CGContextSetBlendMode(context, kCGBlendModeClear); // first clean underlying stuff
//		CGContextAddPath(context, bezierPath.CGPath);
//		CGContextStrokePath(context);
		
		CGContextSetBlendMode(context, kCGBlendModeNormal); // then draw over a clear surface
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextStrokePath(context);
		
		CGContextRestoreGState(context);
	
	}
	
	if (usingTitle || anImage) {
	
		CGContextSetAllowsAntialiasing(context, YES);
		CGContextSetShouldAntialias(context, YES);
		
		CGContextSetAllowsFontSmoothing(context, YES);
		CGContextSetShouldSmoothFonts(context, YES);
	
		CGRect contentRect = (CGRect){
			(CGPoint){
				contentOffset.x + insets.left + floorf(0.5 * (finalSize.width - insets.left - insets.right - contentSize.width)), 
				contentOffset.y + floorf(0.5 * (finalSize.height - contentSize.height))
			}, finalSize
		};
		
		CGRect titleRect = (CGRect){
			(CGPoint){
				contentRect.origin.x + titleOffset.x,
				contentRect.origin.y + titleOffset.y
			},
			titleSize
		};
		
		CGRect imageRect = (CGRect){
			(CGPoint){
				contentRect.origin.x + imageOffset.x,
				contentRect.origin.y + imageOffset.y
			},
			imageSize
		};
	
		CGContextSaveGState(context);
		CGContextSetShadowWithColor(context, usingTitleShadow.offset, usingTitleShadow.spread, usingTitleShadow.color.CGColor);
		CGContextSetFillColorWithColor(context, usingTitleColor.CGColor);
		
		CGContextBeginTransparencyLayer(context, NULL);
		
		[usingTitle drawInRect:titleRect withFont:usingFont];

		if (anImage) {
			
			CGContextConcatCTM(context, CGAffineTransformScale(CGAffineTransformTranslate(CGAffineTransformIdentity, 0, CGRectGetHeight(contentRect)), 1, -1));
			
			CGContextClipToMask(context, imageRect, anImage.CGImage);
			CGContextFillRect(context, imageRect);
			
		}
		
		CGContextEndTransparencyLayer(context);
		
		CGContextRestoreGState(context);
	
	}
	
	CGContextEndTransparencyLayer(context);
	
	UIImage *returnedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return returnedImage;	

}

@end
