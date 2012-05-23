//
//  IRBindingsHelperContext.m
//  IRFoundations
//
//  Created by Evadne Wu on 5/23/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRBindingsHelperContext.h"
#import "IRLifetimeHelper.h"

@interface IRBindingsHelperContext ()

@property (nonatomic, readwrite, weak) id source;
@property (nonatomic, readwrite, copy) NSString *sourceKeyPath;

@property (nonatomic, readwrite, weak) id target;
@property (nonatomic, readwrite, copy) NSString *targetKeyPath;

@property (nonatomic, readwrite, assign) BOOL assignsOnMainThread;
@property (nonatomic, readwrite, copy) IRBindingsValueTransformer valueTransformer;

@property (nonatomic, readwrite, assign) BOOL dead;
@property (nonatomic, readwrite, assign) const void * sourcePtr;

- (void) dieIfAppropriate;

@end


@implementation IRBindingsHelperContext

@synthesize source, sourceKeyPath, target, targetKeyPath, assignsOnMainThread, valueTransformer;
@synthesize dead, sourcePtr;

- (id) initWithSource:(id)inSource keyPath:(NSString *)inSourceKeyPath target:(id)inTarget keyPath:(NSString *)inTargetKeyPath options:(NSDictionary *)inOptions {

	NSCParameterAssert(inSource);
	NSCParameterAssert(inSourceKeyPath);
	NSCParameterAssert(inTarget);
	NSCParameterAssert(inTargetKeyPath);
	
	self = [super init];
	if (!self)
		return nil;
		
	self.source = inSource;
	self.sourceKeyPath = inSourceKeyPath;
	self.target = inTarget;
	self.targetKeyPath = inTargetKeyPath;
	self.assignsOnMainThread = [[inOptions objectForKey:kIRBindingsAssignOnMainThreadOption] boolValue];
	self.valueTransformer = [inOptions objectForKey:kIRBindingsValueTransformerBlock];
	
	[self.source addObserver:self forKeyPath:self.sourceKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:(__bridge void *)self];
	
	self.sourcePtr = (__bridge const void *)inSource;
	
	__weak IRBindingsHelperContext *wSelf = self;
	
	[self.source irPerformOnDeallocation:^{
	
		[wSelf dieIfAppropriate];
	
	}];
	
	return self;

}

- (id) init {

	return [self initWithSource:nil keyPath:nil target:nil keyPath:nil options:nil];

}

- (void) dieIfAppropriate {

	if (!self.dead) {
	
		id usedSource = self.source ? self.source : (__bridge id)self.sourcePtr;
		[usedSource removeObserver:self forKeyPath:self.sourceKeyPath context:(__bridge void *)self];
		
		self.dead = YES;

	}

}

- (void) dealloc {
	
	[self dieIfAppropriate];

}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

	id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
	id newValue = [change objectForKey:NSKeyValueChangeNewKey];
	NSString *changeKind = [change objectForKey:NSKeyValueChangeKindKey];
	id setValue = newValue;
		
	IRBindingsValueTransformer valueTransformerOrNil = self.valueTransformer;
	if (valueTransformerOrNil)
		setValue = valueTransformerOrNil(oldValue, newValue, changeKind);
	
	BOOL assignmentOnMainThread = self.assignsOnMainThread;

	if ([setValue isEqual:[NSNull null]])
		setValue = nil;

	id ownerRef = self.target;
	NSString *capturedKeyPath = self.targetKeyPath;
	void (^operation)() = ^ {
		[ownerRef setValue:setValue forKeyPath:capturedKeyPath];
	};

	if (assignmentOnMainThread && ![NSThread isMainThread])
		dispatch_async(dispatch_get_main_queue(), operation);
	else
		operation();

}


@end
