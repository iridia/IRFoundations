//
//  IRImageUnarchiveFromDataTransformer.m
//  Instaphoto
//
//  Created by Evadne Wu on 6/13/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRImageUnarchiveFromDataTransformer.h"

@implementation IRImageUnarchiveFromDataTransformer

+ (void) initialize {

	[NSValueTransformer setValueTransformer:[[[self alloc] init] autorelease] forName:NSStringFromClass([self class])];

}

+ (Class) transformedValueClass {

	return [UIImage class];

}

+ (BOOL) allowsReverseTransformation {

	return YES;

}

- (id)reverseTransformedValue:(id)value {

	if (!value)
		return nil;
	
	if(![value isKindOfClass:[NSData class]])
		[NSException raise:NSInternalInconsistencyException format:@"Value (%@) is not an NSData instance", [value class]];
		
	return [UIImage imageWithData:value];
	
}

- (id) transformedValue:(id)value {

	if (![value isKindOfClass:[UIImage class]])
		return nil;
	
	return UIImagePNGRepresentation(value);

}

@end
