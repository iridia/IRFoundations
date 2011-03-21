//
//  IRLabel.m
//  Milk
//
//  Created by Evadne Wu on 2/14/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRLabel.h"


@implementation IRLabel

+ (IRLabel *) labelWithFont:(UIFont *)aFont color:(UIColor *)aColor {

	IRLabel *returnedLabel = [[self alloc] init];
	returnedLabel.font = aFont;
	returnedLabel.textColor = aColor;
	returnedLabel.minimumFontSize = aFont.pointSize;
	returnedLabel.adjustsFontSizeToFitWidth = NO;
	
	return [returnedLabel autorelease];

}

@end
