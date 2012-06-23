//
//  MLFlushGlowingSegmentedControl.m
//  IRFoundations
//
//  Created by Evadne Wu on 12/1/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import "IRSegmentedControl.h"
#import "IRSegmentedControlSegment.h"





@interface IRSegmentedControl ()

@property (nonatomic, readwrite, retain) IRTransparentToolbar *toolbar;

- (void) handleSegmentTap:(id)sender;
- (void) handleTouchUpInside:(id)sender;

@end





@implementation IRSegmentedControl

@synthesize items, toolbar, selectedSegmentIndex, usesAlternateImages;
@synthesize delegate;





- (id) initWithFrame:(CGRect)inFrame {

	self = [super initWithFrame:inFrame]; if (!self) return nil;
	
	self.toolbar = [[IRTransparentToolbar alloc] initWithFrame:inFrame];
	self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	[self addSubview:self.toolbar];
	
	return self;

}

- (NSArray *) items {

	return self.toolbar.items;

}

- (void) setItems:(NSArray *)inArray {

//	This internal copy will prove useful
	items = [inArray copy];
	
	for (UIBarButtonItem *barButtonItem in inArray)
	((IRSegmentedControlSegment *)(barButtonItem.customView)).delegate = self;
	
	//	[((IRSegmentedControlSegment *)(barButtonItem.customView)).trackingButton addTarget:self action:@selector(handleTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

	[self.toolbar setItems:inArray];

}

- (void) handleSegmentTap:(id)sender {

	[self handleTouchUpInside:sender];

}

- (void) handleTouchUpInside:(id)sender {

	NSInteger index = -1;	
	NSInteger result = NSNotFound;

	for (UIBarButtonItem *barButtonItem in self.toolbar.items) {
	
		index ++;
	
		if (![barButtonItem.customView isKindOfClass:[IRSegmentedControlSegment class]])
		continue;
				
		if (((IRSegmentedControlSegment *)(barButtonItem.customView)) != sender)
		continue;
		
		result = index;
	
	}
	
	if (result != NSNotFound)
	[self setSelectedSegmentIndex:result];

}

- (void) setSelectedSegmentIndex:(NSInteger)inIndex {

	if (selectedSegmentIndex == inIndex)
	if ([self segmentAtIndex:inIndex] != nil)
	if (((IRSegmentedControlSegment *)[self segmentAtIndex:inIndex]).active)
		return;

	selectedSegmentIndex = inIndex;

	[[self items] enumerateObjectsWithOptions:0 usingBlock: ^ (id inObject, NSUInteger objectIndex, BOOL *stop) {
	
		((IRSegmentedControlSegment *)(((UIBarButtonItem *)inObject).customView)).active = (objectIndex == selectedSegmentIndex);
	
	}];
	
	[self.delegate segmentedControl:self didSelectSegmentAtIndex:inIndex];

}

- (void) setUsesAlternateImages:(BOOL)inUsesAlternateImages {

	if (self.usesAlternateImages == inUsesAlternateImages) return;

	usesAlternateImages = inUsesAlternateImages;

	[items enumerateObjectsWithOptions:0 usingBlock: ^ (id inObject, NSUInteger inIndex, BOOL *stop) {
	
		((IRSegmentedControlSegment *)(((UIBarButtonItem *)inObject).customView)).usesAlternateImages = self.usesAlternateImages;
	
	}];

}





- (IRSegmentedControlSegment *) segmentAtIndex:(NSUInteger)inIndex {

	UIBarButtonItem *plausibleItem = (UIBarButtonItem *)[[self items] objectAtIndex:inIndex];
	
	if ([plausibleItem.customView isKindOfClass:[IRSegmentedControlSegment class]])
	return (IRSegmentedControlSegment *)(plausibleItem.customView);
	
	return nil;

}





- (NSUInteger) indexOfSegment:(IRSegmentedControlSegment *)inSegment {

	return [items indexOfObject:inSegment];

}





- (void) setTarget:(id)inTarget action:(SEL)inAction forSegmentAtIndex:(NSUInteger)inIndex {

	[[self segmentAtIndex:inIndex] setTrackingButtonTarget:inTarget action:inAction];

}

- (void) setActive:(BOOL)inActive forSegmentAtIndex:(NSUInteger)inIndex animated:(BOOL)inAnimated {

	[[self segmentAtIndex:inIndex] setActive:inActive animated:inAnimated];

}

- (void) setHighlighted:(BOOL)inHighlighted forSegmentAtIndex:(NSUInteger)inIndex animated:(BOOL)inAnimated {

	[[self segmentAtIndex:inIndex] setHighlighted:inHighlighted animated:inAnimated];

}





@end




