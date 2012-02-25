//
//  UITableViewCell+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/21/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "UITableViewCell+IRAdditions.h"

@implementation UITableViewCell (IRAdditions)

+ (id) irCellFromNib {

	return [self irCellFromNibNamed:NSStringFromClass([self class]) instantiatingOwner:nil withOptions:nil];

}

+ (id) irCellFromNibNamed:(NSString *)nibName instantiatingOwner:(id)owner withOptions:(NSDictionary *)options {

	UINib *nib = [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]];
	NSArray *loadedObjects = [nib instantiateWithOwner:nil options:nil];
	
	for (id loadedObject in loadedObjects)	
	if ([loadedObject isKindOfClass:[self class]])
		return loadedObject;
	
	return [[NSSet setWithArray:loadedObjects] anyObject];

}

- (CGFloat) irHeightForCellWithIdentifier:(NSString *)identifier {

	return 44.0f;

}

@end
