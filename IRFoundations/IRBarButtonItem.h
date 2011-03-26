//
//  IRBarButtonItem.h
//  IRFoundations
//
//  Created by Evadne Wu on 3/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IRBarButtonItem : UIBarButtonItem

+ (id) itemWithCustomView:(UIView *)aView;

@property (nonatomic, readwrite, copy) void (^block)();

@end
