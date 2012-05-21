//
//  IRObservings.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/8/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRObservings.h"
#import "IRLifetimeHelper.h"


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

@interface IRObservingsHelper ()

@property (nonatomic, readwrite, assign) id owner;
@property (nonatomic, readwrite, copy) IRObservingsCallbackBlock callback;
@property (nonatomic, readwrite, copy) NSString *observedKeyPath;
@property (nonatomic, readwrite, assign) void *context;

@property (nonatomic, readwrite, assign) void *lastOldValue;
@property (nonatomic, readwrite, assign) void *lastNewValue;

- (void) kill;

@end


@implementation NSObject (IRObservings)

- (NSMutableDictionary *) irObservingsHelpers {

	NSMutableDictionary *associatedHelpers = objc_getAssociatedObject(self, &kAssociatedIRObservingsHelpers);
	if (!associatedHelpers) {
		associatedHelpers = [NSMutableDictionary dictionary];
		objc_setAssociatedObject(self, &kAssociatedIRObservingsHelpers, associatedHelpers, OBJC_ASSOCIATION_RETAIN);
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

- (id) irObserve:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context withBlock:(IRObservingsCallbackBlock)block {

	NSParameterAssert(keyPath);
	NSParameterAssert(options);
	NSParameterAssert(block);
	
	id returnedHelper = [[IRObservingsHelper alloc] initWithObserverBlock:block withOwner:self keyPath:keyPath options:options context:context];
	[[self irObservingsHelperBlocksForKeyPath:keyPath] addObject:returnedHelper];
	
	return returnedHelper;
	

}

- (id) irAddObserverBlock:(IRObservingsLegacyCallbackBlock)aBlock forKeyPath:(NSString *)aKeyPath options:(NSKeyValueObservingOptions)options context:(void *)context {

	NSParameterAssert(aBlock);
	NSParameterAssert(aKeyPath);
	NSParameterAssert(options);
	
	return [self irObserve:aKeyPath options:options context:context withBlock:^(NSKeyValueChange kind, id fromValue, id toValue, NSIndexSet *indices, BOOL isPrior) {
	
		aBlock(fromValue, toValue, kind);
		
	}];

}

- (void) irObserveObject:(id)target keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context withBlock:(IRObservingsCallbackBlock)block {

	id helper = [target irObserve:keyPath options:options context:context withBlock:block];
	
	__weak NSObject *wSelf = self;
	__weak id wHelper = helper;
	__weak id wTarget = target;
	
	[wSelf irPerformOnDeallocation:^{
	
		if (wHelper) {
			[wTarget irRemoveObservingsHelper:wHelper];
		}
		
	}];

}


- (void) irRemoveObservingsHelper:(id)aHelper {

	IRObservingsHelper *castHelper = (IRObservingsHelper *)aHelper;
	NSParameterAssert([castHelper isKindOfClass:[IRObservingsHelper class]]);
	
	[[self irObservingsHelperBlocksForKeyPath:castHelper.observedKeyPath] removeObject:castHelper];
	[castHelper kill];

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
	
	for (IRObservingsHelper *aHelper in removedHelpers)
		[aHelper kill];

	[allHelpers removeObjectsInArray:removedHelpers];

}

@end


@implementation IRObservingsHelper

@synthesize owner, callback, observedKeyPath, context;
@synthesize lastOldValue, lastNewValue;

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
	
	if ((self.lastOldValue != (__bridge void *)(oldValue)) && (self.lastNewValue != (__bridge void *)(newValue))) {
	
		NSKeyValueChange changeKind = NSKeyValueChangeSetting;
		NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
		BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] isEqual:(id)kCFBooleanTrue];
		
		[[change objectForKey:NSKeyValueChangeKindKey] getValue:&changeKind];
		
		if (self.callback)
			self.callback(changeKind, oldValue, newValue, indices, isPrior);
		
		self.lastOldValue = (__bridge void *)(oldValue);
		self.lastNewValue = (__bridge void *)(newValue);
	
	}

}

- (void) kill {

	if (owner && observedKeyPath)
		[owner removeObserver:self forKeyPath:observedKeyPath];
	
	self.owner = nil;
	self.observedKeyPath = nil;
	self.callback = nil;

}

- (void) dealloc {

	[self kill];

} 

@end





