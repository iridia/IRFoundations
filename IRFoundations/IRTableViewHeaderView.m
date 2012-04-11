//
//  IRTableViewHeaderView.m
//  IRFoundations
//
//  Created by Evadne Wu on 11/16/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import "IRTableViewHeaderView.h"


@interface IRTableViewHeaderView ()

@property (nonatomic, retain, readwrite) UILabel *titleLabel;
@property (nonatomic, retain, readwrite) UIView *auxiliaryViewContainer;
@property (nonatomic, retain, readwrite) UIView *auxiliaryView;

@end


@implementation IRTableViewHeaderView

@synthesize titleLabel, auxiliaryView, auxiliaryViewContainer;

- (id) initWithFrame:(CGRect)inFrame title:(NSString *)inTitle {
    
	self = [super initWithFrame:inFrame];

	if (!self) return nil;
	
	titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(
	
		40,
		CGRectGetHeight(inFrame) - 32,
		CGRectGetWidth(inFrame) - 80,
		24
		
	)];
	
	titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
	titleLabel.textColor = [UIColor colorWithRed:76.0f/255.0f green:86.0f/255.0f blue:108.0f/255.0f alpha:1.0f];
	titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.65f];
	titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
	
	titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
	
	titleLabel.text = inTitle;
	titleLabel.backgroundColor = [UIColor clearColor];
	
	[titleLabel sizeToFit];
	
	auxiliaryViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
	
	[self addSubview:titleLabel];
	[self addSubview:auxiliaryViewContainer];
	
	[self setNeedsLayout];
	
	return self;

}

- (void) setTitle:(NSString *)inTitle {

	self.titleLabel.text = inTitle;
	[self setNeedsLayout];

}

- (void) setAuxiliaryView:(UIView *)inView {

	if (auxiliaryView == inView) return;
	
	[auxiliaryView removeFromSuperview];
	
	auxiliaryView = [inView retain];
	auxiliaryView.alpha = 0.0f;
	[self.auxiliaryViewContainer addSubview:auxiliaryView];
	
	auxiliaryView.center = CGPointMake(self.auxiliaryViewContainer.frame.size.width / 2, self.auxiliaryViewContainer.frame.size.height - auxiliaryView.frame.size.height / 2);
	
	[UIView animateWithDuration:0.25f animations: ^ { 

		auxiliaryView.alpha = 1.0f;
	
	}];

}

- (void) layoutSubviews {

	[self.titleLabel sizeToFit];
	
	if (self.titleLabel.frame.size.width > (CGRectGetWidth(self.frame) - 80 - 32 - 16)) {
	
		self.titleLabel.frame = CGRectMake(
	
			self.titleLabel.frame.origin.x,
			self.titleLabel.frame.origin.y,
			self.titleLabel.frame.size.height,
			CGRectGetWidth(self.frame) - 80 - 32 - 16
			
		);
	
	}
	
	self.auxiliaryViewContainer.frame = CGRectMake(
	
		self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + 4,
		self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height - self.auxiliaryViewContainer.frame.size.height,
		self.auxiliaryViewContainer.frame.size.width,
		self.auxiliaryViewContainer.frame.size.height
	
	);
	
}

- (void) dealloc {

	self.titleLabel = nil;
	self.auxiliaryView = nil;
	self.auxiliaryViewContainer = nil;

	[super dealloc];

}


@end
