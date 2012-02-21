//
//  UITableViewCell+IRAdditions.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/21/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (IRAdditions)

+ (id) irCellFromNib;
+ (id) irCellFromNibNamed:(NSString *)nibName instantiatingOwner:(id)owner withOptions:(NSDictionary *)options;

- (CGFloat) irHeightForCellWithIdentifier:(NSString *)identifier;

@end
