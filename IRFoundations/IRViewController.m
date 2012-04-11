//
//  IRViewController.m
//  IRFoundations
//
//  Created by Evadne Wu on 3/10/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRViewController.h"

@interface IRViewController ()

@end

@implementation IRViewController

@synthesize onShouldAutorotateToInterfaceOrientation, onLoadView, onViewWillAppear, onViewDidAppear, onViewWillDisappear, onViewDidDisappear;

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

	if (self.onShouldAutorotateToInterfaceOrientation)
		return self.onShouldAutorotateToInterfaceOrientation(interfaceOrientation);

	return (interfaceOrientation == UIInterfaceOrientationPortrait);
	
}

- (void) loadView {

	if (self.onLoadView)
		self.onLoadView();
	else
		[super loadView];

}

- (void) viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  
  if (self.onViewWillAppear)
    self.onViewWillAppear();
    
}

- (void) viewDidAppear:(BOOL)animated {

  [super viewDidAppear:animated];
  
  if (self.onViewDidAppear)
    self.onViewDidAppear();

}

- (void) viewWillDisappear:(BOOL)animated {

  [super viewWillDisappear:animated];
  
  if (self.onViewWillDisappear)
    self.onViewWillDisappear();

}

- (void) viewDidDisappear:(BOOL)animated {

  [super viewDidDisappear:animated];
  
  if (self.onViewDidDisappear)
    self.onViewDidDisappear();

}

@end
