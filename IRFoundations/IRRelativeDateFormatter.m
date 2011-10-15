//
//  IRRelativeDateFormatter.m
//  IRFoundations
//
//  Created by Evadne Wu on 12/23/10.
//  Copyright 2010 Iridia Productions. All rights reserved.
//

#import "IRRelativeDateFormatter.h"


@interface IRRelativeDateFormatter ()

@property (nonatomic, readwrite, retain) NSString *tokenSeparatorComponent;

+ (NSInteger) valueForUnit:(NSCalendarUnit)inCalendarUnit inDateComponents:(NSDateComponents *)inDateComponents;
+ (NSString *) stringRepresentationForValueOfCalendarUnit:(NSCalendarUnit)inCalendarUnit dateComponents:(NSDateComponents *)inDateComponents;
+ (NSArray *) stringRepresentationFormatterStringsforCalendarUnit:(NSCalendarUnit)inCalendarUnit past:(BOOL)inRepresentingDateInThePast;

+ (NSString *) wrappedStringRepresentationForString:(NSString *)inString representedDateTimepoint:(IRDateTimepoint)timePoint;	//	NO for future dates

@end



@implementation IRRelativeDateFormatter

static IRRelativeDateFormatter* IRRelativeDateFormatterSharedFormatter;

@synthesize approximationCalendarUnits, tokenSeparatorComponent, approximationMaxTokenCount;

+ (IRRelativeDateFormatter *) sharedFormatter {

//	This negatively impacts performance
//	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSShowNonLocalizedStrings"];
	
	if (!IRRelativeDateFormatterSharedFormatter) {
	
		IRRelativeDateFormatterSharedFormatter = [[self alloc] init];
		
	}
	
	return IRRelativeDateFormatterSharedFormatter;

}

- (id) init {

	self = [super init]; if (!self) return nil;
		
	approximationCalendarUnits = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
	tokenSeparatorComponent = [@" " retain];
	approximationMaxTokenCount = NSUIntegerMax;
	
	return self;

}

- (void) dealloc {

	[tokenSeparatorComponent release];
	
	[super dealloc];

}





+ (NSInteger) valueForUnit:(NSCalendarUnit)inCalendarUnit inDateComponents:(NSDateComponents *)inDateComponents {
		
	switch (inCalendarUnit) {

		case NSEraCalendarUnit: return [inDateComponents era];
		case NSYearCalendarUnit: return [inDateComponents year];
		case NSMonthCalendarUnit: return [inDateComponents month];
		case NSDayCalendarUnit: return [inDateComponents day];
		case NSHourCalendarUnit: return [inDateComponents hour];
		case NSMinuteCalendarUnit: return [inDateComponents minute];
		case NSSecondCalendarUnit: return [inDateComponents second];
		case NSWeekCalendarUnit: return [inDateComponents week];
		case NSWeekdayCalendarUnit: return [inDateComponents weekday];
		case NSWeekdayOrdinalCalendarUnit: return [inDateComponents weekdayOrdinal];
		case NSQuarterCalendarUnit: return [inDateComponents quarter];
		default: return 0;

	};

}

+ (NSArray *) stringRepresentationFormatterStringsforCalendarUnit:(NSCalendarUnit)inCalendarUnit past:(BOOL)inRepresentingDateInThePast {

//	This could be locale specific, but we are not dealing with it now

//	if (inRepresentingDateInThePast) {
	
		switch (inCalendarUnit) {
	
			case NSEraCalendarUnit: return [NSArray arrayWithObjects:@"%d Era", @"%d Eras", nil];
			case NSYearCalendarUnit: return [NSArray arrayWithObjects:@"%d Year", @"%d Years", nil];
			case NSMonthCalendarUnit: return [NSArray arrayWithObjects:@"%d Month", @"%d Months", nil];
			case NSDayCalendarUnit: return [NSArray arrayWithObjects:@"%d Day", @"%d Days", nil];
			case NSHourCalendarUnit: return [NSArray arrayWithObjects:@"%d Hour", @"%d Hours", nil];
			case NSMinuteCalendarUnit: return [NSArray arrayWithObjects:@"%d Minute", @"%d Minutes", nil];
			case NSSecondCalendarUnit: return [NSArray arrayWithObjects:@"%d Second", @"%d Seconds", nil];
			case NSWeekCalendarUnit: return [NSArray arrayWithObjects:@"%d Week", @"%d Weeks", nil];
			case NSWeekdayCalendarUnit: return [NSArray arrayWithObjects:@"%d Workday", @"%d Workdays", nil];
			case NSWeekdayOrdinalCalendarUnit: return [NSArray arrayWithObjects:@"%d Ordinal Workday", @"%d Ordinal Workdays", nil];
			case NSQuarterCalendarUnit: return [NSArray arrayWithObjects:@"%d Quarter", @"%d Quarters", nil];
			default: return nil;
		
		}
	
//	} else {
	
	
//	}

}

+ (NSString *) stringRepresentationForValueOfCalendarUnit:(NSCalendarUnit)inCalendarUnit dateComponents:(NSDateComponents *)inDateComponents {

	NSUInteger value = [self valueForUnit:inCalendarUnit inDateComponents:inDateComponents];
	if (value == 0)
		return @"";
	
	NSArray *availableRepresentations = [self stringRepresentationFormatterStringsforCalendarUnit:inCalendarUnit past:NO];
	
	NSString *finalFormatterString = [availableRepresentations objectAtIndex:(MIN([availableRepresentations count], ABS(value)) - 1)];
	
	if ([finalFormatterString rangeOfString:@"%d"].location == NSNotFound) {
	
		NSLog(@"Warning: formatter string for calendar unit %lu is malformed, does not contain formatter.", (unsigned long)inCalendarUnit);
		return @"";
	
	}
	
	return [NSString stringWithFormat:finalFormatterString, ABS(value)];

}

+ (NSString *) wrappedStringRepresentationForString:(NSString *)inString representedDateTimepoint:(IRDateTimepoint)timePoint {

	switch (timePoint) {
  case IRDateTimepointPast:
		return [NSString stringWithFormat:@"%@ ago", inString];
  case IRDateTimepointNow:
		return inString;
  case IRDateTimepointFuture:
		return [NSString stringWithFormat:@"%@ later", inString];
	}
	
}










- (NSString *) stringForObjectValue:(id)obj {

	if (!obj || ![obj isKindOfClass:[NSDate class]])
	return nil;
	
	NSDate *incomingDate = (NSDate *)obj, *currentDate = [NSDate date];
	NSTimeInterval dateDelta = ceilf([currentDate timeIntervalSinceDate:incomingDate]);
	
	if (dateDelta <= 5)
	return [[self class] wrappedStringRepresentationForString:@"Just Now" representedDateTimepoint:IRDateTimepointNow];

	static NSCalendar *currentCalendar = nil;
	
	if (!currentCalendar)
	currentCalendar = [[NSCalendar currentCalendar] retain];
	
	NSDateComponents *components = [currentCalendar components:self.approximationCalendarUnits fromDate:incomingDate toDate:currentDate options:0];
	BOOL dateIsInThePast = (dateDelta > 0);
	
	NSMutableString *returnedString = [NSMutableString string];
	
	BOOL shouldAppendTokenSeparator = NO;
	
	int consumedTokens = 0;

	int calendarUnit; for (calendarUnit = kCFCalendarUnitEra; calendarUnit <= kCFCalendarUnitSecond; calendarUnit = (calendarUnit << 1)) {
	
		if (!(self.approximationCalendarUnits & calendarUnit))
		continue;
		
		NSString *representationStringForToken = [[self class] stringRepresentationForValueOfCalendarUnit:calendarUnit dateComponents:components];
		if (!representationStringForToken || [representationStringForToken isEqual:@""])
		continue;
		
		consumedTokens++;
		
		if (consumedTokens > approximationMaxTokenCount)
		break;
		
		if (shouldAppendTokenSeparator)
		[returnedString appendString:self.tokenSeparatorComponent];
		[returnedString appendString:representationStringForToken];
		
		shouldAppendTokenSeparator = YES;
	
	}
	
	return [[self class] wrappedStringRepresentationForString:returnedString representedDateTimepoint:(dateIsInThePast ? IRDateTimepointPast : IRDateTimepointFuture)];

}

@end
