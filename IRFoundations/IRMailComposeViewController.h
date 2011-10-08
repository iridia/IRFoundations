//
//  IRMailComposeViewController.h
//  IRFoundations
//
//  Created by Evadne Wu on 5/13/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#ifndef __IRMailComposeViewController__
#define __IRMailComposeViewController__

typedef void (^IRMailComposeViewControllerCallback)(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error);

#endif

@interface IRMailComposeViewController : MFMailComposeViewController

+ (IRMailComposeViewController *) controllerWithMessageToRecipients:(NSArray *)toRecipients withSubject:(NSString *)aSubject messageBody:(NSString *)messageBody inHTML:(BOOL)messageIsHTML completion:(void(^)(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error))aBlock;

@property (nonatomic, readwrite, copy) IRMailComposeViewControllerCallback callback;

@end
