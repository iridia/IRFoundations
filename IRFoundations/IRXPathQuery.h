//
//  IRXPathQuery.h
//  IRFoundations
//
//  Created by Evadne Wu on 2/10/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//
//  Internal XPath implementation adpoted from:
//  http://cocoawithlove.com/2008/10/using-libxml2-for-parsing-and-xpath.html





#import <Foundation/Foundation.h>

#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>





@class IRXMLNode;
@interface IRXPathQuery : NSObject

+ (NSArray *) queryDocument:(NSData *)aDocument usingXPath:(NSString *)aXPath;
+ (NSArray *) queryHTMLDocument:(NSData *)aDocument usingXPath:(NSString *)aXPath;

+ (NSArray *) performXPathQueryOnDocument:(xmlDocPtr)aDocument usingXPath:(NSString *)aXPath;
+ (IRXMLNode *) representationForNode:(xmlNodePtr)currentNode parent:(IRXMLNode *)parentOrNil;

@end





@interface IRXMLNode : NSObject

+ (IRXMLNode *) nodeWithName:(NSString *)aName;

@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, retain) NSString *content;
@property (nonatomic, readonly, retain) NSMutableDictionary *attributes;	//	Contains 
@property (nonatomic, readonly, retain) NSMutableArray *children;

@end



