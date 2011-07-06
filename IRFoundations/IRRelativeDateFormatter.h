//
//  IRRelativeDateFormatter.h
//
//  IRRelativeDateFormatter.m
//  IRFoundations
//
//  Created by Evadne Wu on 12/23/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>





#ifndef __IRRelativeDateFormatter__
#define __IRRelativeDateFormatter__

#define IRRelativeDateFormatterLocalizedString(key, comment) \
[[NSBundle bundleForClass:[IRRelativeDateFormatter class]] localizedStringForKey:(key) value:@"" table:@"IRRelativeDateFormatter"]

typedef enum {

	IRDateTimepointPast,
	IRDateTimepointNow,
	IRDateTimepointFuture

} IRDateTimepoint;


#endif





@interface IRRelativeDateFormatter : NSDateFormatter {

}

+ (IRRelativeDateFormatter *) sharedFormatter;

- (NSString *) stringForObjectValue:(id)obj;

@property (nonatomic, readwrite, assign) NSCalendarUnit approximationCalendarUnits;

	//	Use bitmasks to alter the behavior.
	//	default is NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit.


@property (nonatomic, readwrite, assign) NSUInteger approximationMaxTokenCount;

	//	number of maximum approximations to output in a string.
	//	e.g. 1 -> “2 hours”,  2 -> “2 hours 30 minutes” 3 -> “2 hours 30 minutes 30 seconds”, etc.
	//	default is NSUIntegerMax which means everything.

@end
	
		
	
	
	