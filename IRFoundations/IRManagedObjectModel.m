//
//  IRManagedObjectModel.m
//  IRFoundations
//
//  Created by Evadne Wu on 10/18/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRManagedObjectModel.h"
#import "NSFetchRequest+IRAdditions.h"

NSString * const IRFetchRequestTemplateNameUserInfoKey = @"Name";
NSString * const IRFetchRequestTemplateSubstitutionVariablesUserInfoKey = @"SubstitutionVariables";

@implementation IRManagedObjectModel

- (NSFetchRequest *) fetchRequestFromTemplateWithName:(NSString *)name substitutionVariables:(NSDictionary *)variables {

	NSFetchRequest *fetchRequest = [super fetchRequestFromTemplateWithName:name substitutionVariables:variables];
	fetchRequest.userInfo = @{
		IRFetchRequestTemplateNameUserInfoKey: name,
		IRFetchRequestTemplateSubstitutionVariablesUserInfoKey: variables
	};
	
	return fetchRequest;

}

- (NSFetchRequest *) fetchRequestTemplateForName:(NSString *)name {

	NSFetchRequest *fetchRequest = [super fetchRequestTemplateForName:name];
	fetchRequest.userInfo = @{
		IRFetchRequestTemplateNameUserInfoKey: name
	};
	
	return fetchRequest;

}

@end
