//
//  IRTableViewController.h
//  IRFoundations
//
//  Created by Evadne Wu on 1/12/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "IRTableView.h"





@interface IRTableViewController : UITableViewController

@property (nonatomic, retain) IRTableView *tableView;

@property (nonatomic, readwrite, assign) BOOL swizzlesTableViewOnLoadView;
@property (nonatomic, readwrite, assign) UITableViewStyle tableViewStyle;
@property (nonatomic, readwrite, copy) void (^onLoadView)();

- (void) irConfigure;

//	The overriding point for all initializers — remember to call super.


# pragma mark -
# pragma mark UI Persistence

@property (nonatomic, readwrite, assign) BOOL persistsContentOffset;
@property (nonatomic, readwrite, assign) BOOL persistsContentInset;

//	Defaults to YES.  If YES, restores the always-persisted content offset / inset.  Works together with Core Data integration.


- (NSString *) persistenceIdentifier;

//	If nil, no persistence takes place.  How the identifier gets transformed to a key is an implementation detail.


- (NSMutableDictionary *) persistenceRepresentation;
- (void) restoreFromPersistenceRepresentation:(NSDictionary *)inPersistenceRepresentation;

//	subclasses may get the dictionary from -persistenceRepresentation, and use it directly.


- (void) persistState;
- (void) restoreState;

@property (nonatomic, readwrite, assign) BOOL persistsStateWhenViewWillDisappear;
@property (nonatomic, readwrite, assign) BOOL restoresStateWhenViewWillAppear;

//	Called on -viewWillDisappear:, -viewWillAppear:.  If you do custom reloading, like a forced -reloadData, remember to call them.
//	These methods are helpers that use information from -persistenceRepresentation, -restoreFromPersistenceRepresentation:.

//	Both properties defaults to YES.

@end
