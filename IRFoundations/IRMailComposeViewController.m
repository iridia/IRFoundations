//
//  IRMailComposeViewController.m
//  IRFoundations
//
//  Created by Evadne Wu on 5/13/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRMailComposeViewController.h"

@interface IRMailComposeViewController () <MFMailComposeViewControllerDelegate>

@end


@implementation IRMailComposeViewController
@synthesize callback;

+ (IRMailComposeViewController *) controllerWithMessageToRecipients:(NSArray *)toRecipients withSubject:(NSString *)aSubject messageBody:(NSString *)messageBody inHTML:(BOOL)messageIsHTML completion:(void(^)(MFMailComposeViewController *controller, MFMailComposeResult result, NSError *error))aBlock {

	IRMailComposeViewController *returnedController = [[[self alloc] init] autorelease];
	
	[returnedController setSubject:aSubject];
	[returnedController setToRecipients:toRecipients];
	[returnedController setMessageBody:messageBody isHTML:messageIsHTML];
	
	returnedController.mailComposeDelegate = returnedController;
	returnedController.callback = aBlock;
	
	return returnedController;

}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {

	if (self.callback)
	self.callback(self, result, error);

}

- (void) dealloc {

	[callback release];
	[super dealloc];

}

@end
