//
//  IRActionSheetController.m
//  Milk
//
//  Created by Evadne Wu on 2/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRActionSheetController.h"

#import "IRActionSheet.h"


@interface IRActionSheetController ()

@property (nonatomic, readwrite, retain) IRActionSheet *managedActionSheet;
@property (nonatomic, readwrite, assign) BOOL behavingProgrammatically;

- (IRAction *) actionAtIndex:(NSUInteger)index usingActionSheet:(UIActionSheet *)anActionSheet;

@end


@implementation IRActionSheetController

@synthesize title, cancellationAction, destructionAction, otherActions, onActionSheetCancel, onActionSheetWillPresent, onActionSheetDidPresent, onActionSheetWillDismiss, onActionSheetDidDismiss, managedActionSheet;

@synthesize behavingProgrammatically;

+ (IRActionSheetController *) actionSheetControllerWithTitle:(NSString *)aTitle cancelAction:(IRAction *)cancellationAction destructiveAction:(IRAction *)destructionAction otherActions:(NSArray *)otherActionsOrNil {

	IRActionSheetController *controller = [[self alloc] init];
	if (!controller) return nil;
	
	controller.title = aTitle;
	controller.cancellationAction = cancellationAction;
	controller.destructionAction = destructionAction;
	controller.otherActions = otherActionsOrNil;
	
	return [controller autorelease];

}

- (id) init {
	
	self = [super init];
	if (!self) return nil;
	
	self.behavingProgrammatically = NO;
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillChangeStatusBarOrientationNotification:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
	
	return self;

}

- (void) dealloc {

	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[title release];
	[cancellationAction release];
	[destructionAction release];
	[otherActions release];
	
	[managedActionSheet setDelegate:nil];
	[managedActionSheet release];
	
	[onActionSheetCancel release];
	[onActionSheetWillPresent release];
	[onActionSheetDidPresent release];
	[onActionSheetWillDismiss release];
	[onActionSheetDidDismiss release];
	
	[super dealloc];

}

- (UIActionSheet *) singleUseActionSheet {

	IRActionSheet *returnedActionSheet = [[IRActionSheet alloc] initWithTitle:self.title delegate:self cancelButtonTitle:self.cancellationAction.title destructiveButtonTitle:self.destructionAction.title otherButtonTitles:nil];
	
	for (IRAction *anOtherAction in self.otherActions)
	[returnedActionSheet addButtonWithTitle:anOtherAction.title];
	
	return [returnedActionSheet autorelease];

}

- (UIActionSheet *) managedActionSheet {

	if (!managedActionSheet) {
	
		managedActionSheet = [[self singleUseActionSheet] retain];
	
	}
	
	return managedActionSheet;

}

- (IRAction *) actionAtIndex:(NSUInteger)buttonIndex usingActionSheet:(UIActionSheet *)actionSheet {

	NSUInteger cancelButtonIndex = [actionSheet cancelButtonIndex];
	NSUInteger destructiveButtonIndex = [actionSheet destructiveButtonIndex];
	
	if (buttonIndex == cancelButtonIndex) {
	
		return self.cancellationAction;
	
	} else if (buttonIndex == destructiveButtonIndex) {
	
		return self.destructionAction;
	
	} else {
	
		IRAction *selectedAction = [self.otherActions objectAtIndex:(( ^ {
		
			NSUInteger finalIndex = buttonIndex;
			
			if (buttonIndex > cancelButtonIndex)
			finalIndex--;
			
			if (buttonIndex > destructiveButtonIndex)
			finalIndex--;
			
			return finalIndex;
		
		})())];
		
		return selectedAction;
	
	}

}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

	[[self actionAtIndex:buttonIndex usingActionSheet:actionSheet] invoke];
	
}

- (void) actionSheetCancel:(UIActionSheet *)actionSheet {

	if (self.onActionSheetCancel)
	self.onActionSheetCancel();

}

- (void) willPresentActionSheet:(UIActionSheet *)actionSheet {

//	Retain self.  This is to combat a situation where the controller is used on its own as an autoreleased object
//	In that sense it might be autoreleased before the action sheet is dismissed
	[self retain];

	if (self.onActionSheetWillPresent)
	self.onActionSheetWillPresent();

}

- (void) didPresentActionSheet:(UIActionSheet *)actionSheet {

	if (self.onActionSheetDidPresent)
	self.onActionSheetDidPresent();

}

- (void) actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {

	if (self.onActionSheetWillDismiss)
	self.onActionSheetWillDismiss([self actionAtIndex:buttonIndex usingActionSheet:actionSheet]);	

}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

	if (actionSheet == managedActionSheet)
	self.managedActionSheet = nil;
	
	if (self.onActionSheetDidDismiss)
	self.onActionSheetDidDismiss([self actionAtIndex:buttonIndex usingActionSheet:actionSheet]);

//	Release self.  This is to combat a situation where the controller is used on its own as an autoreleased object
//	In that sense it might be autoreleased before the action sheet is dismissed
	[self autorelease];

}





- (void) handleApplicationWillChangeStatusBarOrientationNotification:(NSNotification *)notification {

	[self retain];
	
	[self.managedActionSheet prepareForReshowingIfAppropriate];
	
}

- (void) handleApplicationDidChangeStatusBarOrientationNotification:(NSNotification *)notification {

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.125 * NSEC_PER_SEC), dispatch_get_main_queue(), ^ {
	 
		[self.managedActionSheet reshowIfAppropriate];
		
		[self autorelease];

	});
	
}

@end
