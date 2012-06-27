//
//  IRImageUnarchiveFromDataTransformer.m
//  Instaphoto
//
//  Created by Evadne Wu on 6/13/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRImageUnarchiveFromDataTransformer.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define IRImage UIImage
#else
#import <AppKit/AppKit.h>
#define IRImage NSImage
#endif

@implementation IRImageUnarchiveFromDataTransformer

+ (void) initialize {

	[NSValueTransformer setValueTransformer:[[self alloc] init] forName:NSStringFromClass([self class])];

}

+ (Class) transformedValueClass {

	return [IRImage class];

}

+ (BOOL) allowsReverseTransformation {

	return YES;

}

- (id)reverseTransformedValue:(id)value {

	if (!value)
		return nil;
	
	if(![value isKindOfClass:[NSData class]])
		[NSException raise:NSInternalInconsistencyException format:@"Value (%@) is not an NSData instance", [value class]];
		
	return [[IRImage alloc] initWithData:value];
	
}

- (id) transformedValue:(id)value {

	if (![value isKindOfClass:[IRImage class]])
		return nil;
	
#if TARGET_OS_IPHONE
	return UIImagePNGRepresentation(value);
#else
	return [value TIFFRepresentation];
#endif

}

@end
