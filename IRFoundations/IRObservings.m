//
//  IRObservings.m
//  Milk
//
//  Created by Evadne Wu on 2/8/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRObservings.h"





NSString * const kAssociatedIRObservingsHelpers = @"kAssociatedIRObservingsHelpers";


@interface IRObservingsHelper : NSObject

- (id) initWithObserverBlock:(IRObservingsCallbackBlock)block withOwner:(id)owner keyPath:(NSString *)keypath options:(NSKeyValueObservingOptions)options context:(void *)context;

@property (nonatomic, readonly, assign) id owner;
@property (nonatomic, readonly, copy) IRObservingsCallbackBlock callback;
@property (nonatomic, readonly, copy) NSString *observedKeyPath;
@property (nonatomic, readonly, assign) void *context;

@end

@interface NSObject (IRObservingsPrivate)

@property (nonatomic, readonly, retain) NSMutableDictionary *irObservingsHelpers;

@end





@implementation NSObject (IRObservings)

- (NSMutableDictionary *) irObservingsHelpers {

	NSMutableDictionary *associatedHelpers = objc_getAssociatedObject(self, kAssociatedIRObservingsHelpers);
	
	if (!associatedHelpers) {
	
		associatedHelpers = [NSMutableDictionary dictionary];
		
		objc_setAssociatedObject(self, kAssociatedIRObservingsHelpers, associatedHelpers, OBJC_ASSOCIATION_RETAIN);
			
	}
	
	return associatedHelpers;

}

- (NSMutableArray *) irObservingsHelperBlocksForKeyPath:(NSString *)aKeyPath {

	NSMutableArray *returnedArray = [self.irObservingsHelpers objectForKey:aKeyPath];
	
	if (!returnedArray) {
	
		returnedArray = [NSMutableArray array];
		[self.irObservingsHelpers setObject:returnedArray forKey:aKeyPath];
	
	}
	
	return returnedArray;

}

- (id) irAddObserverBlock:(void(^)(id inOldValue, id inNewValue, NSString *changeKind))aBlock forKeyPath:(NSString *)aKeyPath options:(NSKeyValueObservingOptions)options context:(void *)context {

	id returnedHelper = [[[IRObservingsHelper alloc] initWithObserverBlock:aBlock withOwner:self keyPath:aKeyPath options:options context:context] autorelease];
	[[self irObservingsHelperBlocksForKeyPath:aKeyPath] addObject:returnedHelper];
	
	return returnedHelper;

}

- (void) irRemoveObservingsHelper:(id)aHelper {

	IRObservingsHelper *castHelper = (IRObservingsHelper *)aHelper;
	NSParameterAssert([castHelper isKindOfClass:[IRObservingsHelper class]]);
	
	[[self irObservingsHelperBlocksForKeyPath:castHelper.observedKeyPath] removeObject:castHelper];

}

- (void) irRemoveObserverBlocksForKeyPath:(NSString *)keyPath {

	[self irRemoveObserverBlocksForKeyPath:keyPath context:nil];

}

- (void) irRemoveObserverBlocksForKeyPath:(NSString *)keyPath context:(void *)context {

	NSMutableArray *allHelpers = [self irObservingsHelperBlocksForKeyPath:keyPath];
	NSArray *removedHelpers = allHelpers;
	
	if (context) {
		
		removedHelpers = [allHelpers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock: ^ (IRObservingsHelper *aHelper, NSDictionary *bindings) {
			return (BOOL)(aHelper.context == context);
		}]];
		
	}

	[allHelpers removeObjectsInArray:removedHelpers];

}

@end





@interface IRObservingsHelper ()

@property (nonatomic, readwrite, assign) id owner;
@property (nonatomic, readwrite, copy) IRObservingsCallbackBlock callback;
@property (nonatomic, readwrite, copy) NSString *observedKeyPath;
@property (nonatomic, readwrite, assign) void *context;

@end

@implementation IRObservingsHelper

@synthesize owner, callback, observedKeyPath, context;

- (id) initWithObserverBlock:(IRObservingsCallbackBlock)block withOwner:(id)inOwner keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)inContext {

	self = [super init];
	if (!self) return nil;
	
	self.owner = inOwner;
	self.observedKeyPath = keyPath;
	self.callback = block;
	self.context = inContext;
	
	[self.owner addObserver:self forKeyPath:keyPath options:options context:inContext];
	
	return self;

}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

	id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	NSString *changeKind = [change objectForKey:NSKeyValueChangeKindKey];
	
	if (self.callback)
	self.callback(oldValue, newValue, changeKind);

}

- (void) dealloc {

	[self.owner removeObserver:self forKeyPath:self.observedKeyPath];
	
	self.owner = nil;
	self.observedKeyPath = nil;
	self.callback = nil;
	
	[super dealloc];

} 

@end





