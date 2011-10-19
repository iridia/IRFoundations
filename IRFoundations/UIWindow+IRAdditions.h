//
//  UIWindow+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 9/7/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const IRWindowInterfaceBoundsDidChangeNotification;
extern NSString * const IRWindowInterfaceChangeUnderlyingKeyboardNotificationKey;	//	In the notification’s user info, wraps around the original notification
extern NSString * const IRWindowInterfaceChangeNewBoundsKey;	//	In the notification’s user info, wraps around window.irInterfaceBounds

extern NSString * const IRInterfaceBoundsKey;	//	KVO-able on the window

@interface UIWindow (IRAdditions)

//	Returns a CGRect that is guaranteed not to be covered by elements such as the UIKeyboard
@property (nonatomic, readonly, assign) CGRect irInterfaceBounds;

@end
