//
//  IRHTMLStringFormatter.m
//  xpathTest
//
//  Created by Evadne Wu on 2/4/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRHTMLStringFormatter.h"


@interface IRHTMLStringFormatter ()

@property (nonatomic, readwrite, retain) NSSet *skippedTagNames;
@property (nonatomic, readwrite, retain) NSSet *linebreakingTagNames;
@property (nonatomic, readwrite, retain) NSAttributedString *whitespace;
@property (nonatomic, readwrite, retain) NSAttributedString *linebreak;
@property (nonatomic, readwrite, assign) NSStringEncoding stringConversionEncoding; // Default: NSUTF8StringEncoding
@property (nonatomic, readwrite, retain) NSMutableDictionary *attributeParsers;

@end


@implementation IRHTMLStringFormatter

@synthesize skippedTagNames, linebreakingTagNames, whitespace, linebreak, stringConversionEncoding, attributeParsers;

+ (IRHTMLStringFormatter *) sharedFormatter {

	static IRHTMLStringFormatter *returnedFormatter = nil;
	
	if (!returnedFormatter) {
	
		returnedFormatter = [[self alloc] init];
	
	}
	
	return returnedFormatter;

}

- (id) init {

	self = [super init];
	if (!self) return nil;
	
	self.skippedTagNames = [NSSet setWithObjects:
	
		@"iframe",
	
	nil];
	
	self.linebreakingTagNames = [NSSet setWithObjects:
	
		@"p", @"div", 
	
	nil];
	
	self.whitespace = [[[NSAttributedString alloc] initWithString:@" " attributes:nil] autorelease];
	self.linebreak = [[[NSAttributedString alloc] initWithString:@"\n" attributes:nil] autorelease];
	
	self.stringConversionEncoding = NSUTF8StringEncoding;
	
	self.attributeParsers = [NSMutableDictionary dictionary];
	
	return self;

}

- (void) dealloc {

	self.skippedTagNames = nil;
	self.linebreakingTagNames = nil;
	self.whitespace = nil;
	self.linebreak = nil;
	self.attributeParsers = nil;
	
	[super dealloc];

}





- (NSAttributedString *) attributedStringForHTMLString:(NSString *)string {
	
	return [self attributedStringForHTMLData:[string dataUsingEncoding:self.stringConversionEncoding allowLossyConversion:YES]];

}





- (NSAttributedString *) attributedStringForHTMLData:(NSData *)data {

#if 1
#ifdef DEBUG

	NSLog(@"attributedStringForHTMLData %@ \n %@", data, [[[NSString alloc] initWithData:data encoding:self.stringConversionEncoding] autorelease]);

#endif	
#endif

	NSArray *queriedResponse = nil;
	
	@try {

		queriedResponse = [IRXPathQuery queryHTMLDocument:data usingXPath:@"////body"];
		
	} @catch (NSException *exception) {
	
		NSLog(@"Exception: %@", exception);
		return nil;
		
	}
	
	NSMutableAttributedString *returnedString = [[[NSMutableAttributedString alloc] initWithString:@"" attributes:nil] autorelease];

	for (IRXMLNode *aNode in queriedResponse)
	[returnedString appendAttributedString:[self attributedStringForHTMLNode:aNode]];
	
	return returnedString;

}





- (NSAttributedString *) attributedStringForHTMLNode:(IRXMLNode *)aNode {
	
	NSMutableAttributedString *workingString = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
	
	if ([self skipsTagNamed:aNode.name])
	return workingString;
	
	NSMutableDictionary *attributes = [self textAttributesForHTMLNode:aNode];
	
	if ([self insertsLinebreakBeforeTagNamed:aNode.name])
	[workingString appendAttributedString:self.linebreak];
	
	if ([aNode.name isEqual:@"br"]) {

		if (aNode.content == nil)
		if ([aNode.children count] == 0) {
		
		//	Just appended a linebreak.  Do the same for this one.  Somebody hate <p> tags and just don’t use them.  Go away.
			[workingString appendAttributedString:self.linebreak];
			return workingString;
		
		}
	
	}
	
	if (aNode.content != nil) {
	
		NSString *appendedContent = aNode.content;
		
		if (![aNode.name isEqual:@"pre"]) {
		
			NSLog(@"Appending from a block that has better come without newlines");
			appendedContent = [aNode.content stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
			
		}
		
		[workingString appendAttributedString:[[[NSAttributedString alloc] initWithString:appendedContent] autorelease]];
		
	}
	
	NSMutableArray *childrenStrings = [NSMutableArray array];
	for (IRXMLNode *aChildNode in aNode.children) {
		
		NSAttributedString *aChildString = [self attributedStringForHTMLNode:aChildNode];
		
		if ([[aChildString string] length] != 0)
		[childrenStrings addObject:aChildString];
		
	}
	
	
	void (^addWhitespace)() = ^ { [workingString appendAttributedString:self.whitespace]; };
	
	if ([aNode.content length] > 0)
	if ([childrenStrings count] > 0)
	addWhitespace();
	
	[childrenStrings enumerateObjectsUsingBlock: ^ (NSAttributedString *aChildrenString, NSUInteger idx, BOOL *stop) {
		
		if (idx != 0)
		addWhitespace();
		
		[workingString appendAttributedString:aChildrenString];
	
	}];
	
	
	NSMutableAttributedString *returnedString = [[[NSMutableAttributedString alloc] initWithString:[workingString string]] autorelease];
	
	if ([[attributes allKeys] count] > 0)
	[returnedString addAttributes:attributes range:NSMakeRange(0, [[returnedString string] length])];
	
	[workingString enumerateAttributesInRange:NSMakeRange(0, [workingString length]) options:0 usingBlock: ^ (NSDictionary *attrs, NSRange range, BOOL *stop) {
	
		if (!attrs || [attrs count] == 0) return;
	
		[returnedString setAttributes:attrs range:range];
	
	}];
	
	
//	[returnedString appendAttributedString:self.whitespace];

//	Maybe: if no children, append trailing whitespace.  Not going to do that now, seems risque.
	return returnedString;

}










- (BOOL) skipsTagNamed:(NSString *)aTagName {

	return ([[[[self.skippedTagNames copy] autorelease] objectsWithOptions:NSEnumerationConcurrent passingTest: ^ (NSString *aComparedTagName, BOOL *stop) {
	
		return (BOOL)[aComparedTagName isEqual:aTagName];
	
	}] count] != 0);

}

- (BOOL) insertsLinebreakBeforeTagNamed:(NSString *)aTagName {

	return ([[[[self.linebreakingTagNames copy] autorelease] objectsWithOptions:NSEnumerationConcurrent passingTest: ^ (NSString *aComparedTagName, BOOL *stop) {
	
		return (BOOL)[aComparedTagName isEqual:aTagName];
	
	}] count] != 0);

}










- (NSMutableDictionary *) textAttributesForHTMLNode:(IRXMLNode *)aHTMLNode {

	NSMutableDictionary *returnedDictionary = [NSMutableDictionary dictionary];
	
	for (NSString *anAttributeName in aHTMLNode.attributes) {
	
		IRXMLNode *anAttributeNode = [aHTMLNode.attributes objectForKey:anAttributeName];
			
		NSString *attributeName = anAttributeNode.name;
		NSString *attributeValue = anAttributeNode.content;
		
		if (![self generateTextAttributesForHTMLTagNamed:aHTMLNode.name attribute:attributeName value:attributeValue mutatingDictionary:&returnedDictionary]) {
		
			NSLog(@"Attributes can’t be generated for <%@> %@ = %@", anAttributeName, attributeName, attributeValue);
			
		}
	
	}
	
	return returnedDictionary;

}





- (IRHTMLAttributeParser) attributeParserForTag:(NSString *)aTagNameOrNil attributeName:(NSString *) anAttributeNameOrNil {

	return [self.attributeParsers valueForKeyPath:[NSString stringWithFormat:@"%@.%@",
	
		(aTagNameOrNil ? aTagNameOrNil : @"global"),
		(anAttributeNameOrNil ? anAttributeNameOrNil : @"global")
	
	]];

}

- (void) setAttributeParser:(IRHTMLAttributeParser)aParser forTag:(NSString *)aTagNameOrNil attributeName:(NSString *) anAttributeNameOrNil {

	aTagNameOrNil = aTagNameOrNil ? aTagNameOrNil : @"global";
	anAttributeNameOrNil = anAttributeNameOrNil ? anAttributeNameOrNil : @"global";

	NSMutableDictionary *tagSpecificDictionary = [self.attributeParsers objectForKey:aTagNameOrNil];
	if (!tagSpecificDictionary) {
	
		tagSpecificDictionary = [NSMutableDictionary dictionary];
		[self.attributeParsers setObject:tagSpecificDictionary forKey:aTagNameOrNil];
	
	}
	
	[tagSpecificDictionary setObject:[[aParser copy] autorelease] forKey:anAttributeNameOrNil];

}

- (BOOL) generateTextAttributesForHTMLTagNamed:(NSString *)aTagName attribute:(NSString *)anAttributeName value:(NSString *)anAttributeValue mutatingDictionary:(NSMutableDictionary **)modifiedDictionary {
	
	NSMutableArray *usedParsers = [NSMutableArray array];
	
	for (NSString *aKeyPath in [NSArray arrayWithObjects:
	
		@"global.global",
		[NSString stringWithFormat:@"global.%@", anAttributeName],
		[NSString stringWithFormat:@"%@.global", aTagName],
		[NSString stringWithFormat:@"%@.%@", aTagName, anAttributeName],
	
	nil]) {
	
		IRHTMLAttributeParser aParser = [self.attributeParsers valueForKeyPath:aKeyPath];
		
		if (aParser != nil)
		[usedParsers addObject:aParser];
	
	}
	
	for (IRHTMLAttributeParser aParser in usedParsers) {

		if (!aParser(anAttributeName, anAttributeValue, *modifiedDictionary))
		return NO;
		
	}

	return YES;

}

@end
