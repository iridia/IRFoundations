//
//  IRHTMLStringFormatter.h
//  xpathTest
//
//  Created by Evadne Wu on 2/4/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//





#import <Foundation/Foundation.h>

#import "IRXPathQuery.h"


#ifndef __IRHTMLAttributeParser__
#define __IRHTMLAttributeParser__

typedef BOOL (^IRHTMLAttributeParser) (NSString *inHTMLAttributeName, NSString *inHTMLAttributeValue, NSMutableDictionary *modifiedDictionary);

#endif





@interface IRHTMLStringFormatter : NSObject

+ (IRHTMLStringFormatter *) sharedFormatter;

@property (nonatomic, readonly, retain) NSSet *skippedTagNames;
@property (nonatomic, readonly, retain) NSSet *linebreakingTagNames;
@property (nonatomic, readonly, retain) NSAttributedString *whitespace;
@property (nonatomic, readonly, retain) NSAttributedString *linebreak;
@property (nonatomic, readonly, assign) NSStringEncoding stringConversionEncoding; // Default: NSUTF8StringEncoding

// @property (nonatomic, readwrite, assign) BOOL insertsWhitespaceBetweenTags;

- (NSAttributedString *) attributedStringForHTMLData:(NSData *)data;
- (NSAttributedString *) attributedStringForHTMLString:(NSString *)string;
- (NSAttributedString *) attributedStringForHTMLNode:(IRXMLNode *)aNode;

- (BOOL) skipsTagNamed:(NSString *)aTagName;	// talks with skippedTagNames, checks for inclusion.  Should not override.
- (BOOL) insertsLinebreakBeforeTagNamed:(NSString *)aTagName;	// talks with linebreakingTagNames, checks for inclusion.  Should not override.





@property (nonatomic, readonly, retain) NSMutableDictionary *attributeParsers;

//	Access patterns:
//	attributeParsers.<aTagName>.<anAttributeName>
//	attributeParsers.global.<anAttributeName>
//	attributeParsers.<aTagNameOrGlobal>.global


- (IRHTMLAttributeParser) attributeParserForTag:(NSString *)aTagNameOrNil attributeName:(NSString *) anAttributeNameOrNil;
- (void) setAttributeParser:(IRHTMLAttributeParser)aParser forTag:(NSString *)aTagNameOrNil attributeName:(NSString *) anAttributeNameOrNil;

//	If passed nil, uses @"global", in both aTagNameOrNil, and anAttributeNameOrNil


- (NSMutableDictionary *) textAttributesForHTMLNode:(IRXMLNode *)aHTMLNode;
- (BOOL) generateTextAttributesForHTMLTagNamed:(NSString *)aTagName attribute:(NSString *)anAttributeName value:(NSString *)anAttributeValue mutatingDictionary:(NSMutableDictionary **)modifiedDictionary;

//	The former is used in higher level methods.  The latter is the concrete one.
//	-generateTextAttributesForHTMLAttribute:value:mutatingDictionary: will walk the whole tree containing parsers, and is an internal helper to -textAttributesForHTMLNode:

@end
