//
//  MLAccordionViewController.h
//  IRFoundations
//
//  Created by Evadne Wu on 12/11/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface IRAccordionView : UIView

@property (nonatomic, readwrite, assign) BOOL autoresizes;
@property (nonatomic, readwrite, assign) CGSize minSize;
@property (nonatomic, readwrite, assign) CGSize maxSize;

@end





@interface IRAccordionViewController : UITableViewController

@property (nonatomic, readwrite, retain) NSArray *accordionViews;

@end
