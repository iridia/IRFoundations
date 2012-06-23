//
//  IRStoryboard.h
//  IRFoundations
//
//  Created by Evadne Wu on 4/16/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IRStoryboard : UIStoryboard

@end


@interface UIViewController (IRStoryboardAdditions)

@property (nonatomic, readonly, copy) NSString *storyboardIdentifier;

@end
