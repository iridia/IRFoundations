//
//  NSBundle+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/23/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSBundle+IRAdditions.h"

@implementation NSBundle (IRAdditions)

- (NSString *) debugVersionString {

	NSDictionary *bundleInfo = [self infoDictionary];
	NSString *versionString = [NSString stringWithFormat:@"%@ %@ (%@) # %@", [bundleInfo objectForKey:(id)kCFBundleNameKey], [bundleInfo objectForKey:@"CFBundleShortVersionString"], [bundleInfo objectForKey:(id)kCFBundleVersionKey], [bundleInfo objectForKey:@"IRCommitSHA"]];
	
	return versionString;

}

@end
