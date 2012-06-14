//
//  IRBindingsHelper.m
//  IRFoundations
//
//  Created by Evadne Wu on 5/23/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRBindingsHelper.h"
#import "IRBindingsHelperContext.h"
#import "IRBindings.h"

@interface IRBindingsHelper ()

@property (nonatomic, readwrite, retain) NSMutableDictionary *boundLocalKeyPathsToRemoteObjectContexts;

- (IRBindingsHelperContext *) contextForBoundKeyPath:(NSString *)keyPath;
- (void) setContext:(IRBindingsHelperContext *)context forBoundKeyPath:(NSString *)keyPath;

@end

@implementation IRBindingsHelper

@synthesize owner, boundLocalKeyPathsToRemoteObjectContexts;

- (NSMutableDictionary *) boundLocalKeyPathsToRemoteObjectContexts {

	if (!boundLocalKeyPathsToRemoteObjectContexts)
		boundLocalKeyPathsToRemoteObjectContexts = [NSMutableDictionary dictionary];
	
	return boundLocalKeyPathsToRemoteObjectContexts;

}

- (IRBindingsHelperContext *) contextForBoundKeyPath:(NSString *)keyPath {
	
	return [self.boundLocalKeyPathsToRemoteObjectContexts objectForKey:keyPath];

}

- (void) setContext:(IRBindingsHelperContext *)context forBoundKeyPath:(NSString *)keyPath {

	if (context) {
		
		[self.boundLocalKeyPathsToRemoteObjectContexts setObject:context forKey:keyPath];
		
	} else {
		
		[self.boundLocalKeyPathsToRemoteObjectContexts removeObjectForKey:keyPath];
		
	}

}

- (void) irBind:(NSString *)inLocalKeyPath toObject:(id)inRemoteObject keyPath:(NSString *)inRemoteKeyPath options:(NSDictionary *)inOptions {

	IRBindingsHelperContext *context = [[IRBindingsHelperContext alloc] initWithSource:inRemoteObject keyPath:inRemoteKeyPath target:self.owner keyPath:inLocalKeyPath options:inOptions];
	
	[self setContext:context forBoundKeyPath:inLocalKeyPath];

}

- (void) irUnbind:(NSString *)inLocalKeyPath {

	[self setContext:nil forBoundKeyPath:inLocalKeyPath];

}

- (void) dealloc {

	for (id aLocalKeyPath in [self.boundLocalKeyPathsToRemoteObjectContexts copy])
		[self irUnbind:aLocalKeyPath];
	
	self.boundLocalKeyPathsToRemoteObjectContexts = nil;

}

@end
