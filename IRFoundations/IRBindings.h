//
//  IRBindings.h
//  IRFoundations
//
//  Created by Evadne Wu on 1/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <objc/objc.h>
#import <objc/runtime.h>

#import <Foundation/Foundation.h>

extern NSString * const kIRBindingsAssignOnMainThreadOption;	//	if -isEqual:kCFBooleanTrue, dispatch_async on main queue if ![NSThread isMainThread]
extern NSString * const kIRBindingsValueTransformerBlock;	//	If given block, runs value thru block
typedef id (^IRBindingsValueTransformer) (id inOldValue, id inNewValue, NSString *changeKind);

@interface NSObject (IRBindings)

- (void) irBind:(NSString *)aKeyPath toObject:(id)anObservedObject keyPath:(NSString *)remoteKeyPath options:(NSDictionary *)options;
- (void) irUnbind:(NSString *)aKeyPath;

@end
