//
//  IRActionSheetController.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IRAction.h"

@class IRActionSheet;
@interface IRActionSheetController : NSObject <UIActionSheetDelegate>

+ (IRAction *) defaultCancelAction; // Override for localized title in category (bah)

+ (IRActionSheetController *) actionSheetControllerWithTitle:(NSString *)aTitle cancelAction:(IRAction *)cancellationAction destructiveAction:(IRAction *)destructionAction otherActions:(NSArray *)otherActionsOrNil;

- (IRActionSheet *) singleUseActionSheet;

@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, retain) IRAction *cancellationAction;
@property (nonatomic, readwrite, retain) IRAction *destructionAction;
@property (nonatomic, readwrite, retain) NSArray *otherActions;

@property (nonatomic, readonly, retain) IRActionSheet *managedActionSheet;

//	This is different from the cancel button being tapped
@property (nonatomic, readwrite, copy) void (^onActionSheetCancel)();

@property (nonatomic, readwrite, copy) void (^onActionSheetWillPresent)();
@property (nonatomic, readwrite, copy) void (^onActionSheetDidPresent)();
@property (nonatomic, readwrite, copy) void (^onActionSheetWillDismiss)(IRAction *invokedAction);
@property (nonatomic, readwrite, copy) void (^onActionSheetDidDismiss)(IRAction *invokedAction);

@end
