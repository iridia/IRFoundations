//
//  IRAlertView.h
//  Tarotie
//
//  Created by Evadne Wu on 5/13/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IRAction;

@interface IRAlertView : UIAlertView

+ (IRAlertView *) alertViewWithTitle:(NSString *)aTitle message:(NSString *)aMessage cancelAction:(IRAction *)cancellationAction otherActions:(NSArray *)otherActionsOrNil;

@property (nonatomic, readwrite, retain) IRAction *cancelAction;
@property (nonatomic, readwrite, retain) NSArray *otherActions;

@end
