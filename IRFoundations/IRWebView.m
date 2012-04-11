//
//  IRWebView.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/16/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRWebView.h"
#import "Foundation+IRAdditions.h"

@interface IRWebView ()

@property (nonatomic, readwrite, retain) UIView *overlayView;
@property (nonatomic, readwrite, retain) UIView *backgroundView;

- (void) configure;

@end


@implementation IRWebView

@synthesize overlayView, backgroundView, onScrollViewDidScroll;

- (id) initWithCoder:(NSCoder *)aDecoder {

	self = [super initWithCoder:aDecoder];
	if (!self) return nil;
	
	[self configure];
	
	return self;

}

- (id) initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if (!self) return nil;
	
	[self configure];
				
	return self;

}

- (void) configure {

	self.overlayView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
	self.overlayView.userInteractionEnabled = NO;
	self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self addSubview:self.overlayView];
	
	self.backgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
	self.backgroundView.userInteractionEnabled = NO;
	self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self addSubview:self.backgroundView];
	[self sendSubviewToBack:self.backgroundView];
	
	self.backgroundView.backgroundColor = self.backgroundColor;
	self.backgroundColor = [UIColor clearColor];

}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {

	if ([self irHasDifferentSuperInstanceMethodForSelector:_cmd])
		[super scrollViewDidScroll:scrollView];
	
	if (self.onScrollViewDidScroll)
		self.onScrollViewDidScroll(scrollView);

}

- (void) dealloc {

	[overlayView release];
	[backgroundView release];
	[onScrollViewDidScroll release];
	[super dealloc];

}

- (void) injectHelperScript {

	NSURL *scriptURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"IRWebView+DOMInjecting" withExtension:@"js"];
	
	[self executeJavaScriptWithContentsOfFile:scriptURL];

}

- (NSString *) executeJavaScriptWithContentsOfFile:(NSURL *)aFileURL {

	NSError *error = nil;
	NSStringEncoding usedEncoding = NSUTF8StringEncoding;
	NSString *scriptContents = [NSString stringWithContentsOfURL:aFileURL usedEncoding:&usedEncoding error:&error];
	
	if (!scriptContents) {
	
		NSLog(@"Error: %@", error);
		return nil;
	
	}
	
	return [self stringByEvaluatingJavaScriptFromString:scriptContents];

}

- (void) injectCSSWithContentsOfFile:(NSURL *)aFileURL {

	[self injectHelperScript];
	
	NSError *error = nil;
	NSStringEncoding usedEncoding = NSUTF8StringEncoding;
	NSString *styleContents = [NSString stringWithContentsOfURL:aFileURL usedEncoding:&usedEncoding error:&error];
	
	if (!styleContents) {
	
		NSLog(@"Error: %@", error);
		return;
	
	}
	
	NSString *evaluatedString = [NSString stringWithFormat:@"window.irWebView.injectStyle(unescape(\"%@\"));", [styleContents stringByAddingPercentEscapesUsingEncoding:usedEncoding]];
	
	[self stringByEvaluatingJavaScriptFromString:evaluatedString];
		
}

- (void) lockViewportScaling {

	[self injectHelperScript];
	
	NSString *evaluatedString = @"window.irWebView.lockViewportWidth();";
	
	[self stringByEvaluatingJavaScriptFromString:evaluatedString];

}

@end
