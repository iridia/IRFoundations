//
//  IROptionallyDynamicShapeView.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRStaticShapeView.h"


@interface IRStaticShapeView ()

@property (nonatomic, readwrite, retain) IRStaticShapeViewDrawingView *drawingView;

@end


@implementation IRStaticShapeView

@dynamic backgroundColor;
@synthesize path, shadowColor, shadowOffset, shadowSpread, fillColor, drawingView;

- (id) initWithFrame:(CGRect)frame {
    
	self = [super initWithFrame:frame];
	if (!self) return nil;

	self.drawingView = [[IRStaticShapeViewDrawingView alloc] initWithFrame:self.bounds];
	self.drawingView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.drawingView.dataSource = self;
	[self addSubview:self.drawingView];
	
	self.drawingView.backgroundColor = [UIColor yellowColor]; 
	
	for (NSString *aKeyPath in [NSArray arrayWithObjects:@"frame", @"backgroundColor", @"path", @"shadowColor", @"shadowOffset", @"shadowSpread", @"fillColor", nil])
	[self addObserver:self forKeyPath:aKeyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

	return self;

}

- (void) dealloc {

	for (NSString *aKeyPath in [NSArray arrayWithObjects:@"frame", @"backgroundColor", @"path", @"shadowColor", @"shadowOffset", @"shadowSpread", @"fillColor", nil])
	[self removeObserver:self forKeyPath:aKeyPath];

}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

	if (object != self)
	return;
	
	if ([keyPath isEqual:@"path"])
	[self.drawingView setNeedsDisplayInRect:self.drawingView.bounds];

}

@end





@implementation IRStaticShapeViewDrawingView : UIView

@synthesize dataSource;

- (void) drawRect:(CGRect)aRect {

	CGPoint startingPoint = self.frame.origin;
	startingPoint.x = -1 * startingPoint.x;
	startingPoint.y = -1 * startingPoint.y;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (![self.dataSource.backgroundColor isEqual:[UIColor clearColor]]) {
	
		CGContextSetFillColorWithColor(context, self.dataSource.backgroundColor.CGColor);
		CGContextFillRect(context, self.bounds);
	
	}
	
	CGContextTranslateCTM(context, startingPoint.x, startingPoint.y);
	
	CGContextAddPath(context, self.dataSource.path.CGPath);
	
	CGContextSetShadowWithColor(context, self.dataSource.shadowOffset, self.dataSource.shadowSpread, self.dataSource.shadowColor.CGColor);
	CGContextSetFillColorWithColor(context, self.dataSource.fillColor.CGColor);
	CGContextFillPath(context);

}

@end
