//
//  IRSubtitledTableViewCell.m
//  Milk
//
//  Created by Evadne Wu on 11/16/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import "IRSubtitledTableViewCell.h"


@implementation IRSubtitledTableViewCell

@synthesize subtitleLabel, inputField, userInfo;

+ (IRSubtitledTableViewCell *) cell {

	UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"IRSubtitledTableViewCell" bundle:nil];
	
	IRSubtitledTableViewCell *cell = (IRSubtitledTableViewCell *)temporaryController.view;
	[cell retain];
	[temporaryController release];
	
	return [cell autorelease];

}

+ (IRSubtitledTableViewCell *) secureCell {

	IRSubtitledTableViewCell *cell = [self cell];
	cell.inputField.secureTextEntry = YES;
	
	return cell;

}

- (void) dealloc {

	self.subtitleLabel = nil;
	self.inputField = nil;
	self.userInfo = nil;

	[super dealloc];

}

@end
