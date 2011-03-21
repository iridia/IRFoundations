//
//  IRBindings.m
//  Milk
//
//  Created by Evadne Wu on 1/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRBindings.h"





NSString * const kIRBindingsAssignOnMainThreadOption = @"kIRBindingsAssignOnMainThreadOption";

NSString * const kIRBindingsValueTransformerBlock = @"kIRBindingsValueTransformerBlock";

NSString * const kAssociatedIRBindingsHelper = @"kAssociatedIRBindingsHelper";


@interface IRBindingsHelper : NSObject

@property (nonatomic, readwrite, assign) id owner;

- (void) irBind:(NSString *)aKeyPath toObject:(id)anObservedObject keyPath:(NSString *)remoteKeyPath options:(NSDictionary *)options;
- (void) irUnbind:(NSString *)aKeyPath;

@end

@interface NSObject (IRBindingsPrivate)

@property (nonatomic, readonly, retain) IRBindingsHelper *irBindingsHelper;

@end





@implementation NSObject (IRBindings)

- (IRBindingsHelper *) irBindingsHelper {

	IRBindingsHelper *associatedHelper = objc_getAssociatedObject(self, kAssociatedIRBindingsHelper);
	
	if (!associatedHelper) {
	
		associatedHelper = [[IRBindingsHelper alloc] init];
		
		associatedHelper.owner = self;
		
		objc_setAssociatedObject(self, kAssociatedIRBindingsHelper, associatedHelper, OBJC_ASSOCIATION_RETAIN);
		
		[associatedHelper release];
	
	}
	
	associatedHelper.owner = self;
	
	return associatedHelper;

}

- (void) irBind:(NSString *)aKeyPath toObject:(id)anObservedObject keyPath:(NSString *)remoteKeyPath options:(NSDictionary *)options {

	[self irUnbind:aKeyPath];

	[self.irBindingsHelper irBind:aKeyPath toObject:anObservedObject keyPath:remoteKeyPath options:options];

}

- (void) irUnbind:(NSString *)aKeyPath {

	[self.irBindingsHelper irUnbind:aKeyPath];

}

@end










@interface IRBindingsHelper ()

@property (nonatomic, readwrite, retain) NSMutableDictionary *boundLocalKeyPathsToRemoteObjectContexts;

@end





@implementation IRBindingsHelper

@synthesize owner, boundLocalKeyPathsToRemoteObjectContexts;

- (id) init {

	self = [super init];
	if (!self) return nil;
	
	self.boundLocalKeyPathsToRemoteObjectContexts = [NSMutableDictionary dictionary];
	
	return self;

}

- (void) irBind:(NSString *)inLocalKeyPath toObject:(id)inRemoteObject keyPath:(NSString *)inRemoteKeyPath options:(NSDictionary *)inOptions {

	[self irUnbind:inLocalKeyPath];
	
	[self.boundLocalKeyPathsToRemoteObjectContexts setObject:[NSDictionary dictionaryWithObjectsAndKeys:
	
		inRemoteObject, @"object",
		inRemoteKeyPath, @"keyPath",
		(inOptions ? inOptions : [NSNull null]), @"options",
	
	nil] forKey:inLocalKeyPath];
	
	id context = [self.boundLocalKeyPathsToRemoteObjectContexts objectForKey:inLocalKeyPath];
	
	[inRemoteObject addObserver:self forKeyPath:inRemoteKeyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:context];

}

- (void) irUnbind:(NSString *)inLocalKeyPath {

	id originalMetadata = [self.boundLocalKeyPathsToRemoteObjectContexts objectForKey:inLocalKeyPath];
	if (!originalMetadata)
	return;
	
	NSAssert([originalMetadata isKindOfClass:[NSDictionary class]], @"Original metadata is not a dictionary");

	id originallyBoundRemoteObject = [originalMetadata objectForKey:@"object"];
	id originallyBoundRemoteKeyPath = [originalMetadata objectForKey:@"keyPath"];

	[originallyBoundRemoteObject removeObserver:self forKeyPath:originallyBoundRemoteKeyPath];
	[self.boundLocalKeyPathsToRemoteObjectContexts removeObjectForKey:inLocalKeyPath];

}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

	NSArray *allKeysForObject = [self.boundLocalKeyPathsToRemoteObjectContexts allKeysForObject:context];
	
	if (!allKeysForObject || ([allKeysForObject count] == 0)) {

		NSLog(@"%s: No keys for context object.  Unbinding.", __PRETTY_FUNCTION__);
		
		[self.owner irUnbind:keyPath];
	
		return;
	
	}	

	id localKeyPath = [allKeysForObject objectAtIndex:0];
	
	id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	NSString *changeKind = [change objectForKey:NSKeyValueChangeKindKey];
	id setValue = newValue;
	
	NSDictionary *optionsDictionary = [(id)context objectForKey:@"options"];
	optionsDictionary = ([optionsDictionary isEqual:[NSNull null]]) ? nil : optionsDictionary;
		
	IRBindingsValueTransformer valueTransformerOrNil;
	
	if ((valueTransformerOrNil = [optionsDictionary objectForKey:kIRBindingsValueTransformerBlock]))
	setValue = valueTransformerOrNil(oldValue, newValue, changeKind);
	
	if ((setValue != nil) && ![setValue isEqual:[self.owner valueForKeyPath:localKeyPath]]) {
	
		BOOL assignmentOnMainThread = [[optionsDictionary objectForKey:kIRBindingsAssignOnMainThreadOption] boolValue];

		void (^operation)() = ^ {
	
			[self.owner setValue:setValue forKeyPath:localKeyPath];
			
		};
		
		if (assignmentOnMainThread) {
		
			dispatch_async(dispatch_get_main_queue(), operation);
		
		} else {
		
			operation();
		
		}
	
	}

}

- (void) dealloc {

	for (id aLocalKeyPath in [[self.boundLocalKeyPathsToRemoteObjectContexts copy] autorelease])
	[self irUnbind:aLocalKeyPath];
	
	self.boundLocalKeyPathsToRemoteObjectContexts = nil;

	[super dealloc];

}

@end
