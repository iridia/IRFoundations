//
//  UIWindow+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 9/7/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (IRAdditions)

//	Returns a CGRect that is guaranteed not to be covered by elements such as the UIKeyboard
@property (nonatomic, readonly, assign) CGRect irInterfaceBounds;

@end
