//
//  IRTableViewCell.h
//  IRFoundations
//
//  Created by Evadne Wu on 4/11/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IRTableViewCellPrototype <NSObject>

- (CGFloat) heightForRowRepresentingObject:(id)object inTableView:(UITableView *)tableView;

@end


@interface IRTableViewCell : UITableViewCell <NSCopying>

+ (id) cellRepresentingObject:(id)object inTableView:(UITableView *)tableView;
+ (CGFloat) heightForRowRepresentingObject:(id)object inTableView:(UITableView *)tableView;

@property (nonatomic, readonly, weak) id representedObject;

@end


@interface IRTableViewCell (ForSubclassEyesOnly)

+ (UITableViewCellStyle) cellStyle;	//	Returns UITableVieWCellStyleDefault by default
+ (IRTableViewCell<IRTableViewCellPrototype> *) prototypeForIdentifier:(NSString *)identifier;	//	Returns generated prototypes
+ (NSString *) identifierRepresentingObject:(id)object;	//	Returns @"Cell" by default

+ (IRTableViewCell *) newPrototypeForIdentifier:(NSString *)identifier;	//	Override this method to generate new cells

+ (NSSet *) encodedObjectKeyPaths;	//	Cell decoding (prototype -> data -> instance during cell copying) will not work correctly if subviews, for example, in properties are not encoded too 

@property (nonatomic, readwrite, weak) id representedObject;

@end
