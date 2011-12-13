//
//  IRTableViewController.m
//  Milk
//
//  Created by Evadne Wu on 1/12/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRTableViewController.h"


@interface IRTableViewController ()


@end





@implementation IRTableViewController

@dynamic tableView;

@synthesize swizzlesTableViewOnLoadView;
@synthesize tableViewStyle;
@synthesize onLoadView;
@synthesize persistsContentOffset;
@synthesize persistsStateWhenViewWillDisappear;
@synthesize restoresStateWhenViewDidAppear;

- (id) initWithCoder:(NSCoder *)aDecoder {

	self = [super initWithCoder:aDecoder];
	if (!self) return nil;
	
	[self irConfigure];
	return self;

}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (!self) return nil;
	
	[self irConfigure];
	return self;

}

- (id) initWithStyle:(UITableViewStyle)style {

	self = [super initWithStyle:style];
	if (!self) return nil;
	
	[self irConfigure];
	return self;

}

- (void) dealloc {

	self.tableView = nil;
	self.onLoadView = nil;

	[super dealloc];

}

- (void) irConfigure {

	self.tableViewStyle = UITableViewStylePlain;
	self.persistsContentOffset = YES;
	
	self.persistsStateWhenViewWillDisappear = YES;
	self.restoresStateWhenViewDidAppear = YES;

}

- (void) loadView {

	[super loadView];
	
	if (swizzlesTableViewOnLoadView) {

		self.tableView = [IRTableView tableViewWithEncodedDataOfObject:self.tableView];
		
	} else {
	
		self.tableView = [[[IRTableView alloc] initWithFrame:self.view.frame style:self.tableViewStyle] autorelease];
	
	}
	
//	self.view = self.tableView;

	if (self.onLoadView)
	self.onLoadView();

}

- (void) viewDidUnload {

	[super viewDidUnload];
	
//	self.view = nil;
//	self.tableView = nil;

}

- (void) viewDidAppear:(BOOL)animated {

	[super viewDidAppear:animated];
	
	if (self.restoresStateWhenViewDidAppear)
	[self restoreState];
	
}

- (void) viewWillDisappear:(BOOL)animated {

	if (self.persistsStateWhenViewWillDisappear)
	[self persistState];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[super viewWillDisappear:animated];

}

- (void) persistState {

	NSString *persistenceIdentifier = [self persistenceIdentifier];
	if (!persistenceIdentifier) return;
	
	NSDictionary *persistenceRep = [self persistenceRepresentation];
	
	[[NSUserDefaults standardUserDefaults] setObject:persistenceRep forKey:persistenceIdentifier];

}

- (void) restoreState {

	NSString *persistenceIdentifier = [self persistenceIdentifier];
	if (!persistenceIdentifier) return;
	
	NSDictionary *persistenceData = [[NSUserDefaults standardUserDefaults] objectForKey:persistenceIdentifier];
	
	@try {
	
		[self restoreFromPersistenceRepresentation:persistenceData];

	} @catch (NSException *e) {

	//	Remove stale persistence objects
		NSLog(@"Removing stale persistence objects %@", persistenceData);
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:persistenceIdentifier];
		
	}

}

- (NSString *) persistenceIdentifier {

	return NSStringFromClass([self class]);

}

- (NSMutableDictionary *) persistenceRepresentation {

	NSMutableDictionary *persistenceRep = [NSMutableDictionary dictionaryWithObjectsAndKeys:

		NSStringFromCGPoint(self.tableView.contentOffset), @"contentOffset",
		NSStringFromUIEdgeInsets(self.tableView.contentInset), @"contentInset",
	
	nil];
	
	return persistenceRep;

}

- (void) restoreFromPersistenceRepresentation:(NSDictionary *)inPersistenceRepresentation {

	CGPoint	persistedContentOffset = CGPointFromString([inPersistenceRepresentation objectForKey:@"contentOffset"]);
	UIEdgeInsets persistedContentInset = UIEdgeInsetsFromString([inPersistenceRepresentation objectForKey:@"contentInset"]);
	CGFloat persistedTopOffsetSum = persistedContentOffset.y - persistedContentInset.top;
	
	CGPoint	currentContentOffset = self.tableView.contentOffset;
	UIEdgeInsets currentContentInset = self.tableView.contentInset;
	CGFloat currentTopOffsetSum = currentContentOffset.y - currentContentInset.top;
	
	CGPoint newContentOffset = currentContentOffset;
	newContentOffset.y += (persistedTopOffsetSum - currentTopOffsetSum);
	
	newContentOffset.y = MIN(MAX(0, newContentOffset.y), self.tableView.contentSize.height - CGRectGetHeight(self.tableView.bounds));
	
	[self.tableView setContentOffset:newContentOffset animated:NO];

}

@end
