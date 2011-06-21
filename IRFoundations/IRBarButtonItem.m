//
//  IRBarButtonItem.m
//  IRFoundations
//
//  Created by Evadne Wu on 3/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRBarButtonItem.h"


@implementation IRBarButtonItem

@synthesize block;

- (void) dealloc {

	[block release];
	
	[super dealloc];

}

+ (id) itemWithCustomView:(UIView *)aView {

	return [[[self alloc] initWithCustomView:aView] autorelease];

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

	IRBarButtonItem *returnedItem = [self itemWithCustomView:aButton];
	if (!returnedItem) return nil;
	
	returnedItem.block = ^ { aBlock(aButton, returnedItem); };
	
	[aButton addTarget:returnedItem action:@selector(handleCustomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	
	return returnedItem;

}

- (IBAction) handleCustomButtonAction:(id)sender {

	NSParameterAssert(self.block);
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

@end
