//
//  IRBindings.m
//  IRFoundations
//
//  Created by Evadne Wu on 1/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRBindings.h"

#import "IRBindingsHelper.h"

NSString * const kIRBindingsAssignOnMainThreadOption = @"kIRBindingsAssignOnMainThreadOption";
NSString * const kIRBindingsValueTransformerBlock = @"kIRBindingsValueTransformerBlock";
NSString * const kAssociatedIRBindingsHelper = @"kAssociatedIRBindingsHelper";

@implementation NSObject (IRBindings)

- (IRBindingsHelper *) irBindingsHelper {

	IRBindingsHelper *associatedHelper = objc_getAssociatedObject(self, &kAssociatedIRBindingsHelper);
	
	if (!associatedHelper) {
		associatedHelper = [[IRBindingsHelper alloc] init];
		associatedHelper.owner = self;
		objc_setAssociatedObject(self, &kAssociatedIRBindingsHelper, associatedHelper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	
	associatedHelper.owner = self;
	
	return associatedHelper;

}

- (void) irBind:(NSString *)aKeyPath toObject:(id)anObservedObject keyPath:(NSString *)remoteKeyPath options:(NSDictionary *)options {

	[self irUnbind:aKeyPath];

	[[self irBindingsHelper] irBind:aKeyPath toObject:anObservedObject keyPath:remoteKeyPath options:options];

}

- (void) irUnbind:(NSString *)aKeyPath {

	[[self irBindingsHelper] irUnbind:aKeyPath];

}

@end
