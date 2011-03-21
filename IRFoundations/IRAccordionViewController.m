//
//  MLAccordionViewController.m
//  Milk
//
//  Created by Evadne Wu on 12/11/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import "IRAccordionViewController.h"

@interface IRAccordionViewController ()

@property (nonatomic, readwrite, retain) NSMutableArray *calculatedBestAccordionViewCellHeights;
- (NSUInteger) internalIndexForIndexPath:(NSIndexPath *)indexPath;

@end










@interface MLAccordionViewControllerPrivateCell : UITableViewCell

@property (nonatomic, readwrite, assign) IRAccordionView *containedAccordionView;

@end

@implementation MLAccordionViewControllerPrivateCell

@synthesize containedAccordionView;

- (void) setContainedAccordionView:(IRAccordionView *)inView {

	if (containedAccordionView == inView)
	return;
	
	[containedAccordionView removeFromSuperview];

	containedAccordionView = inView;

	[self.contentView addSubview:containedAccordionView];
	
	self.containedAccordionView.frame = self.contentView.bounds;

}

@end






@implementation IRAccordionViewController

@synthesize accordionViews;
@synthesize calculatedBestAccordionViewCellHeights;





- (id) init {

	return [self initWithStyle:UITableViewStylePlain];

}





- (id) initWithStyle:(UITableViewStyle)style {

	self = [super initWithStyle:UITableViewStylePlain]; if (!self) return nil;
	
	self.tableView.delaysContentTouches = NO;
	
	return self;

}





- (void) setAccordionViews:(NSArray *)inArray {

	if (accordionViews == inArray) return;
	
	[accordionViews release];
	accordionViews = nil;

	accordionViews = [inArray retain];
	
	[self.tableView reloadData];

}





- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

//	The catch: we actually do not have any reusable cells

	static NSString *cellIdentifier = @"MLAccordionViewControllerCell";

	id containerCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if (!containerCell || ![containerCell isKindOfClass:[MLAccordionViewControllerPrivateCell class]])
	containerCell = [[[MLAccordionViewControllerPrivateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	
	((MLAccordionViewControllerPrivateCell *)containerCell).containedAccordionView = [self.accordionViews objectAtIndex:[self internalIndexForIndexPath:indexPath]];
	
	return containerCell;

//	return [UIView]

}

- (void) updateTableView {

	[self.tableView reloadData];
		
//	BOOL sumOfContentCellsExceedTableViewHeight

}

- (NSUInteger) internalIndexForIndexPath:(NSIndexPath *)indexPath {

	return indexPath.row;

}





- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	return [(NSNumber *)[self.calculatedBestAccordionViewCellHeights objectAtIndex:[self internalIndexForIndexPath:indexPath]] floatValue];

//	return calculatedTableViewCellHeights

}

@end
