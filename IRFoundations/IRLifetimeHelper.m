//
//  IRLifetimeHelper.m
//  IRFoundations
//
//  Created by Evadne Wu on 10/7/11.
//  Copyright (c) 2011 Iridia Productions. All rights reserved.
//

#import <objc/objc.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import "IRLifetimeHelper.h"


//	@interface NSObject (IRAssociatedStoreAdditions)
//
//	- (void) irRequestAssociatedStoreRemovalOnDeallocation;
//
//	@end
//	
//	
//	void irRemoteAssociatedObjectsAndDeallocate (id self, SEL _cmd) {
//
//		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//		objc_removeAssociatedObjects(self);
//		[pool drain];
//		
//		struct objc_super superInfo = (struct objc_super){
//			self,
//			class_getSuperclass(object_getClass(self))	
//		};
//		
//		objc_msgSendSuper(&superInfo, _cmd);
//		
//	}
//
//
//	@implementation NSObject (IRAssociatedStoreAdditions)
//
//	- (void) irRequestAssociatedStoreRemovalOnDeallocation {
//
//		//	The idea of -requestAssociatedStoreRemovalOnDeallocation is to have the object be a custom subclass…
//		
//		Class ownClass = self->isa;
//		NSString *className = NSStringFromClass(ownClass);
//		
//		const char * prefix = "IRObjectAssociationAutoRemoving_";
//		if (strncmp(prefix, [className UTF8String], strlen(prefix)) == 0)
//			return;
//		
//		NSString *subclassName = [NSString stringWithFormat:@"%s%@", prefix, className];
//		Class subclass = NSClassFromString(subclassName);
//
//		if (subclass)
//			return;
//		
//		subclass = objc_allocateClassPair(ownClass, [subclassName UTF8String], 0);
//		if (!subclass)
//			return;
//		
//		class_replaceMethod(
//			subclass, 
//			@selector(dealloc),
//			(IMP)irRemoteAssociatedObjectsAndDeallocate,
//			"v@:"
//		);
//		
//		objc_registerClassPair(subclass);
//
//		if (subclass)
//			object_setClass(self, subclass);
//
//	}
//
//	@end


static NSString *kIRLifetimeHelpers = @"IRLifetimeHelpers";

@implementation NSObject (IRLifetimeHelperAdditions)

- (void) irPerformOnDeallocation:(void(^)(void))aBlock {

	if ([self retainCount] == UINT_MAX)
		NSLog(@"%s: object is unlikely to be deallocated at all.", __PRETTY_FUNCTION__);
	
	[[self irLifetimeHelpers] addObject:[IRLifetimeHelper helperWithDeallocationCallback:aBlock]];

}

- (NSMutableSet *) irLifetimeHelpers {

	NSMutableSet *returnedSet = objc_getAssociatedObject(self, &kIRLifetimeHelpers);
	if (returnedSet)
		return returnedSet;
	
	returnedSet = [NSMutableSet set];
	objc_setAssociatedObject(self, &kIRLifetimeHelpers, returnedSet, OBJC_ASSOCIATION_RETAIN);
	
	return returnedSet;

}

@end


@implementation IRLifetimeHelper
@synthesize deallocationCallback;

+ (id) helperWithDeallocationCallback:(void(^)(void))aBlock {

	IRLifetimeHelper *returnedHelper = [[self alloc] init];
	returnedHelper.deallocationCallback = aBlock;
	
	return [returnedHelper autorelease];

}

- (void) dealloc {

	if (deallocationCallback)
		deallocationCallback();
	
	[deallocationCallback release];
	[super dealloc];

}

@end
