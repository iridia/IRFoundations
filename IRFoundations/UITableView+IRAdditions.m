//
//  UITableView+IRAdditions.m
//  Iridia Core
//
//  Created by Evadne Wu on 11/16/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import "UITableView+IRAdditions.h"

@implementation UITableView (IRAdditions)

- (UITableViewCell *) nextCellForCell:(UITableViewCell *)inCell {

	UITableView *enclosingTableView = (UITableView *)(inCell.superview);
	if (!enclosingTableView) return nil;
	
	NSIndexPath *referencedCellIndexPath = [enclosingTableView indexPathForCell:inCell];
	
	NSUInteger itemsInSection = [enclosingTableView numberOfRowsInSection:referencedCellIndexPath.section];
	
	if (referencedCellIndexPath.row == (itemsInSection - 1)) {

		if (referencedCellIndexPath.section == ([enclosingTableView numberOfSections] - 1))
		return nil;
	
		itemsInSection = [enclosingTableView numberOfRowsInSection:(referencedCellIndexPath.section + 1)];
		if (itemsInSection == 0) return nil;
		
		return [enclosingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:(referencedCellIndexPath.section + 1)]];
	
	} else {
	
		return [enclosingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(referencedCellIndexPath.row + 1) inSection:referencedCellIndexPath.section]];
	
	}

}

@end