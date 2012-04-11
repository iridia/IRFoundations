//
//  IRTableViewCell.h
//  IRFoundations
//
//  Created by Evadne Wu on 4/11/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IRTableViewCell : UITableViewCell

+ (UITableViewCellStyle) defaultCellStyle;

+ (id) prototypeForIdentifier:(NSString *)identifier;
+ (CGFloat) heightForRowRepresentingObject:(id)object withCellIdentifier:(NSString *)identifier inTableView:(UITableView *)tableView;
- (CGFloat) heightForRowRepresentingObject:(id)object inTableView:(UITableView *)tableView;

@property (nonatomic, readwrite, assign) id representedObject;

@end
