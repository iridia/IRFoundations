//
//  NSString+IRAdditions.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/17/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "NSString+IRAdditions.h"

@implementation NSString (IRAdditions)

- (NSString *) irTailTruncatedStringWithMaxLength:(NSUInteger)maxCharacters {

	return [[self substringToIndex:MIN([self length], maxCharacters)] stringByAppendingString:([self length] > maxCharacters) ? @"…" : @""];

}

@end
