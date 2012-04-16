//
//  UIKit+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/12/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IRAction.h"
#import "IRActionSheet.h"
#import "IRActionSheetController.h"
#import "IRActivityIndicatorView.h"
#import "IRAlertView.h"
#import "IRBarButtonItem.h"
#import "IRBusyView.h"
#import "IRImageUnarchiveFromDataTransformer.h"
#import "IRLabel.h"
#import "IRPaginatedView.h"
#import "IRSegmentedControl.h"
#import "IRSegmentedControlSegment.h"
#import "IRSemiTransparentBarButton.h"
#import "IRSubtitledTableViewCell.h"
#import "IRTableView.h"
#import "IRTableViewController.h"
#import "IRTableViewHeaderView.h"
#import "IRTintedBarButtonItem.h"
#import "IRTransparentToolbar.h"
#import "IRWebView.h"
#import "UIApplication+IRAdditions.h"
#import "UIImage+IRAdditions.h"
#import "UIScrollView+IRAdditions.h"
#import "UITableView+IRAdditions.h"
#import "UIView+IRAdditions.h"
#import "IRView.h"
#import "IRViewController.h"
#import "UIViewController+IRAdditions.h"
#import "UIWindow+IRAdditions.h"
#import "IRPageCurlBarButtonItem.h"
#import "IRTexturedSegmentedControl.h"
#import "IRTableViewCell.h"
#import "IRStackView.h"
#import "IRStoryboard.h"

#if TARGET_OS_IPHONE
#import "IRImagePickerController.h"
#import "IRMailComposeViewController.h"
#endif

extern NSBundle * IRUIKitBundle (void);
extern UIImage * IRUIKitImage (NSString *name);
