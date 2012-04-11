//
//  IRBindings.h
//  IRFoundations
//
//  Created by Evadne Wu on 1/15/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

//  iOS only.  This is not meant to be permanant.

#import <objc/objc.h>
#import <objc/runtime.h>

#import <Foundation/Foundation.h>





extern NSString * const kIRBindingsAssignOnMainThreadOption;

//	In the options dictionary pass a NSNumber which contains YES to this key
//	Otherwise, the assignment can come from any thread


extern NSString * const kIRBindingsValueTransformerBlock;
typedef id (^IRBindingsValueTransformer) (id inOldValue, id inNewValue, NSString *changeKind);

//	Attach a block to the options dictionary and the value returned by that block will be used instead.
//	The block is copied internally.
//	We’re not matching names here; to reuse certain blocks, making them global would generally suffice.
//	The block can also act as a monitor that replaces a huge KVO callback method on an object and enhance locality.





@interface NSObject (IRBindings)

- (void) irBind:(NSString *)aKeyPath toObject:(id)anObservedObject keyPath:(NSString *)remoteKeyPath options:(NSDictionary *)options;
- (void) irUnbind:(NSString *)aKeyPath;

@end




