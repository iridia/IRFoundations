//
//  IRAlertView.m
//  Tarotie
//
//  Created by Evadne Wu on 5/13/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRAlertView.h"
#import "IRAction.h"

@interface IRAlertView () <UIAlertViewDelegate>

@end

@implementation IRAlertView
@synthesize cancelAction, otherActions;

+ (IRAlertView *) alertViewWithTitle:(NSString *)aTitle message:(NSString *)aMessage cancelAction:(IRAction *)cancellationAction otherActions:(NSArray *)otherActionsOrNil {

	IRAlertView *returnedView = [[[self alloc] initWithTitle:aTitle message:aMessage delegate:nil cancelButtonTitle:cancellationAction.title otherButtonTitles:nil] autorelease];
	
	for (IRAction *anAction in otherActionsOrNil)
	[returnedView addButtonWithTitle:anAction.title];
	
	returnedView.delegate = returnedView;
	
	returnedView.title = aTitle;
	returnedView.message = aMessage;
	returnedView.cancelAction = cancellationAction;
	returnedView.otherActions = otherActionsOrNil;
	
	return returnedView;

}

- (void) dealloc {

	[cancelAction release];
	[otherActions release];
	[super dealloc];

}

- (void) alertView:(IRAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	if (buttonIndex == [alertView cancelButtonIndex]) {
	
		[alertView.cancelAction invoke];
	
	} else {
	
		[(IRAction *)[alertView.otherActions objectAtIndex:(NSUInteger)(buttonIndex - ([alertView cancelButtonIndex] == -1 ? 0 : 1))] invoke];
	
	}

}

@end
