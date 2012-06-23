//
//  IRSubtitledTableViewCell.m
//  IRFoundations
//
//  Created by Evadne Wu on 11/16/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import "IRSubtitledTableViewCell.h"


@implementation IRSubtitledTableViewCell

@synthesize subtitleLabel, inputField, userInfo;

+ (IRSubtitledTableViewCell *) cell {

	UINib *bundleNib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:[NSBundle bundleForClass:[self class]]];
	NSArray *bundleObjects = [bundleNib instantiateWithOwner:nil options:nil];
	IRSubtitledTableViewCell *cell = (IRSubtitledTableViewCell *)[bundleObjects objectAtIndex:0];
	
	return cell;

}

+ (IRSubtitledTableViewCell *) secureCell {

	IRSubtitledTableViewCell *cell = [self cell];
	cell.inputField.secureTextEntry = YES;
	
	return cell;

}

@end
