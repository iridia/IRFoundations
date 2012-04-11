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

@interface IRTableViewCell () <IRTableViewCellPrototype>

+ (NSMutableDictionary *) cellPrototypes;

@property (nonatomic, readwrite, weak) id representedObject;

@end


@implementation IRTableViewCell
@synthesize representedObject;

+ (UITableViewCellStyle) cellStyle {

	return UITableViewCellStyleDefault;

}

+ (IRTableViewCell<IRTableViewCellPrototype> *) prototypeForIdentifier:(NSString *)identifier {

	NSMutableDictionary *prototypes = [self cellPrototypes];
	IRTableViewCell *cell = [prototypes objectForKey:identifier];
	
	if (!cell) {
		cell = [self newPrototypeForIdentifier:identifier];
		[self setPrototype:cell forIdentifier:identifier];
	}
	
	return cell;

}

+ (NSString *) identifierRepresentingObject:(id)object {

	return @"Cell";

}

+ (id) cellRepresentingObject:(id)object inTableView:(UITableView *)tableView {

	NSString *identifier = [self identifierRepresentingObject:object];
	IRTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	if (![cell isKindOfClass:[self class]])
		cell = [[self prototypeForIdentifier:identifier] copy];
	
	cell.representedObject = object;
	
	return cell;

}

+ (CGFloat) heightForRowRepresentingObject:(id)object inTableView:(UITableView *)tableView {

	NSString *identifier = [self identifierRepresentingObject:object];
	return [[self prototypeForIdentifier:identifier] heightForRowRepresentingObject:object inTableView:tableView];

}

+ (NSMutableDictionary *) cellPrototypes {

	NSMutableDictionary *dictionary = objc_getAssociatedObject([self class], &kCellPrototypes);
	if (!dictionary) {
		dictionary = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &kCellPrototypes, dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	return dictionary;

}


+ (void) setPrototype:(IRTableViewCell<IRTableViewCellPrototype> *)cell forIdentifier:(NSString *)identifier {

	NSMutableDictionary *prototypes = [self cellPrototypes];
	[prototypes setObject:cell forKey:identifier];

}

+ (IRTableViewCell *) newPrototypeForIdentifier:(NSString *)identifier {

	return [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

}

+ (NSSet *) encodedObjectKeyPaths {

	return nil;

}

- (void) encodeWithCoder:(NSCoder *)aCoder {

	[super encodeWithCoder:aCoder];
	
	for (NSString *keyPath in [[self class] encodedObjectKeyPaths])
		[aCoder encodeObject:[self valueForKeyPath:keyPath] forKey:keyPath];

}

- (id) initWithCoder:(NSCoder *)aDecoder {

	self = [super initWithCoder:aDecoder];

	for (NSString *keyPath in [[self class] encodedObjectKeyPaths])
		[self setValue:[aDecoder decodeObjectForKey:keyPath] forKeyPath:keyPath];
	
	return self;

}

- (CGFloat) heightForRowRepresentingObject:(id)object inTableView:(UITableView *)tableView {

	return tableView.rowHeight;

}

- (id) copyWithZone:(NSZone *)zone {

	id cell = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
	
	return cell;

}

@end
