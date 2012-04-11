//
//  IRParagraphStyle.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/15/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRParagraphStyle.h"


@interface IRParagraphStyle ()

@property (nonatomic, readwrite, retain) NSArray *specifiers;

@end

@implementation IRParagraphStyle
@synthesize specifiers;

- (id) initWithSpecifiers:(NSArray *)inSpecifiers {

	self = [super init];
	if (!self)
		return nil;
	
	specifiers = inSpecifiers;
	
	return self;

}

- (CTParagraphStyleRef) copyCTParagraphStyle {

	NSArray *usedSpecifiers = [self.specifiers copy];
	NSUInteger count = [usedSpecifiers count];
	if (!count)
		return CTParagraphStyleCreate(NULL, 0);
	
	CTParagraphStyleSetting *settings = malloc(sizeof(CTParagraphStyleSetting) * count);
	
	if (!settings)
		return CTParagraphStyleCreate(NULL, 0);
	
	[usedSpecifiers enumerateObjectsUsingBlock:^(IRParagraphStyleSetting *setting, NSUInteger idx, BOOL *stop) {
		settings[idx] = [setting ctParagraphStyleSetting];
	}];

	CTParagraphStyleRef paragraphStyleRef = CTParagraphStyleCreate(settings, count);
	free(settings);
	
	return paragraphStyleRef;

}

@end


@interface IRParagraphStyleSetting ()

@property (nonatomic, readwrite, assign) CTParagraphStyleSpecifier specifier;
@property (nonatomic, readwrite, assign) size_t valueSize;
@property (nonatomic, readwrite, assign) const void * value;

@end

@implementation IRParagraphStyleSetting
@synthesize specifier, valueSize, value;

- (id) initWithSpecifier:(CTParagraphStyleSpecifier)aSpecifier valueSize:(size_t)size value:(const void *)value {

	self = [super init];
	if (!self)
		return nil;
	
	return self;

}

- (CTParagraphStyleSetting) ctParagraphStyleSetting {

	return (CTParagraphStyleSetting){
		specifier,
		valueSize,
		value
	};

}

@end
