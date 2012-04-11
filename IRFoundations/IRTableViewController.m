//
//  IRTableViewController.m
//  IRFoundations
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
@synthesize persistsContentInset;
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
	self.persistsContentInset = YES;
	
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

	return nil;

}

- (NSMutableDictionary *) persistenceRepresentation {

	NSMutableDictionary *persistenceRep = [NSMutableDictionary dictionary];
	
	if (self.persistsContentOffset)
		[persistenceRep setObject:NSStringFromCGPoint(self.tableView.contentOffset) forKey:@"contentOffset"];
		
	if (self.persistsContentInset)
		[persistenceRep setObject:NSStringFromUIEdgeInsets(self.tableView.contentInset) forKey:@"contentInset"];
	
	return persistenceRep;

}

- (void) restoreFromPersistenceRepresentation:(NSDictionary *)inPersistenceRepresentation {

	NSString *persistedContentOffsetRep = [inPersistenceRepresentation objectForKey:@"contentOffset"];
	CGPoint	persistedContentOffset = persistedContentOffsetRep ? CGPointFromString(persistedContentOffsetRep) : CGPointZero;
	
	NSString *persistedContentInsetRep = [inPersistenceRepresentation objectForKey:@"contentInset"];
	UIEdgeInsets persistedContentInset = persistedContentInsetRep ? UIEdgeInsetsFromString(persistedContentInsetRep) : UIEdgeInsetsZero;

	if (self.persistsContentOffset) {
	
		CGFloat usedY = persistedContentOffset.y;
		
		if (self.persistsContentInset)
			usedY = MAX(-1 * persistedContentInset.top, usedY);
	
		persistedContentOffset.y = MIN(usedY, MAX(0, self.tableView.contentSize.height - CGRectGetHeight(self.tableView.bounds)));
		
		if (self.persistsContentInset)
			persistedContentOffset.y = MAX(0, persistedContentOffset.y);
		
		[self.tableView setContentOffset:persistedContentOffset animated:NO];
		
	}

	if (self.persistsContentInset)
		[self.tableView setContentInset:persistedContentInset];

}

@end
