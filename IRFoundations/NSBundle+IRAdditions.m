//
//  NSBundle+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/23/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSBundle+IRAdditions.h"
#import "Foundation+IRAdditions.h"

@implementation NSBundle (IRAdditions)

+ (NSBundle *) irFrameworkBundleWithName:(NSString *)identifier {

	return [[[NSBundle allFrameworks] irMap: ^ (NSBundle *bundle, NSUInteger index, BOOL *stop) {
	
		if ([[[[bundle bundlePath] lastPathComponent] stringByDeletingPathExtension] isEqual:identifier])
			return bundle;

		return (NSBundle *)nil;
	
	}] lastObject];

}

+ (NSBundle *) irFrameworkBundleWithIdentifier:(NSString *)identifier {

	return [[[NSBundle allFrameworks] irMap: ^ (NSBundle *bundle, NSUInteger index, BOOL *stop) {
	
		return [[bundle bundleIdentifier] isEqualToString:identifier] ? bundle : nil;
		
	}] lastObject];

}

- (NSString *) displayVersionString {

	static NSString *string = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		
		NSDictionary *bundleInfo = [self irInfoDictionary];
		
		string = [NSString stringWithFormat:@"%@ %@ (%@)", [bundleInfo objectForKey:@"CFBundleDisplayName"], [bundleInfo objectForKey:@"CFBundleShortVersionString"], [bundleInfo objectForKey:(id)kCFBundleVersionKey]];
		
	});

	return string;

}

- (NSString *) debugVersionString {

	NSDictionary *bundleInfo = [self infoDictionary];
	NSString *versionString = [NSString stringWithFormat:@"%@ %@ (%@) # %@", [bundleInfo objectForKey:(id)kCFBundleNameKey], [bundleInfo objectForKey:@"CFBundleShortVersionString"], [bundleInfo objectForKey:(id)kCFBundleVersionKey], [bundleInfo objectForKey:@"IRCommitSHA"]];
	
	return versionString;

}

- (NSDictionary *) irInfoDictionary {

	NSMutableDictionary *bundleInfo = [[self infoDictionary] mutableCopy];
	[bundleInfo addEntriesFromDictionary:[self localizedInfoDictionary]];
	
	return bundleInfo;

}

@end
