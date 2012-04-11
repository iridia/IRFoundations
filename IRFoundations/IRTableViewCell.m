//
//  IRTableViewCell.m
//  IRFoundations
//
//  Created by Evadne Wu on 4/11/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRTableViewCell.h"
#import <objc/runtime.h>


static NSString * const kCellPrototypes = @"+[IRTableViewCell cellPrototypes]";

@interface IRTableViewCell ()

+ (NSMutableDictionary *) cellPrototypes;

@property (nonatomic, readwrite, assign) IRTableViewCell *prototype;

@end


@implementation IRTableViewCell
@synthesize prototype, representedObject;

+ (UITableViewCellStyle) defaultCellStyle {

	return UITableViewCellStyleDefault;

}

+ (NSMutableDictionary *) cellPrototypes {

	NSMutableDictionary *dictionary = objc_getAssociatedObject([self class], &kCellPrototypes);
	if (!dictionary) {
		dictionary = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &kCellPrototypes, dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return dictionary;

}

+ (id) prototypeForIdentifier:(NSString *)identifier {

	NSMutableDictionary *prototypes = [self cellPrototypes];
	IRTableViewCell *cell = [prototypes objectForKey:identifier];
	
	if (!cell) {
		cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		[prototypes setObject:cell forKey:identifier];
	}
	
	return cell;

}

+ (CGFloat) heightForRowRepresentingObject:(id)object withCellIdentifier:(NSString *)identifier inTableView:(UITableView *)tableView {

	return [[self prototypeForIdentifier:identifier] heightForRowRepresentingObject:object inTableView:tableView];

}

- (CGFloat) heightForRowRepresentingObject:(id)object inTableView:(UITableView *)tableView {

	return tableView.rowHeight;

}

@end
