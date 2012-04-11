//
//  IRXPathQuery.m
//  IRFoundations
//
//  Created by Evadne Wu on 2/10/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRXPathQuery.h"


@implementation IRXPathQuery

+ (NSArray *) queryDocument:(NSData *)aDocument usingXPath:(NSString *)aXPath {

	xmlDocPtr document = NULL;
	document = xmlReadMemory([aDocument bytes], (int)[aDocument length], "", NULL, XML_PARSE_RECOVER);
	
	if (document == NULL) {
	
		[NSException raise:NSInternalInconsistencyException format:@"Could not read XML document."];
		return nil;
	
	}
	
	NSArray *result = [self performXPathQueryOnDocument:document usingXPath:aXPath];
	xmlFreeDoc(document);
	return result;

}

+ (NSArray *) queryHTMLDocument:(NSData *)aDocument usingXPath:(NSString *)aXPath {

	xmlDocPtr document = NULL;
	document = htmlReadMemory([aDocument bytes], (int)[aDocument length], "", NULL, HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR);
	
	if (document == NULL) {
	
		[NSException raise:NSInternalInconsistencyException format:@"Could not read HTML document."];
		return nil;
		
	}
	
	NSArray *result = [self performXPathQueryOnDocument:document usingXPath:aXPath];
	xmlFreeDoc(document);
	return result;

}

+ (NSArray *) performXPathQueryOnDocument:(xmlDocPtr)aDocument usingXPath:(NSString *)aXPath {

	xmlXPathContextPtr xPathContext = NULL;
	xmlXPathObjectPtr xPathObject = NULL; 
	
	xPathContext = xmlXPathNewContext(aDocument);
	if (xPathContext == NULL) {
	
		[NSException raise:NSInternalInconsistencyException format:@"Could not create XML XPath context."];
		return nil;
	
	}
    
	xPathObject = xmlXPathEvalExpression((xmlChar *)[aXPath cStringUsingEncoding:NSUTF8StringEncoding], xPathContext);
	if (xPathObject == NULL) {

		[NSException raise:NSInternalInconsistencyException format:@"Could not evaluate XML XPath %@.", aXPath];
		return nil;

	}
	
	xmlNodeSetPtr xmlNodes = xPathObject->nodesetval;
	if (!xmlNodes) {

		[NSException raise:NSInternalInconsistencyException format:@"XML nodes are NULL."];
		return nil;
	
	}
	
	NSMutableArray *results = [NSMutableArray arrayWithCapacity:(xmlNodes->nodeNr)];
	for (NSInteger i = 0; i < xmlNodes->nodeNr; i++) {

		IRXMLNode *nodeRepresentation = [self representationForNode:xmlNodes->nodeTab[i] parent:nil];
		
		if (nodeRepresentation)
		[results addObject:nodeRepresentation];
	
	}
	
	xmlXPathFreeObject(xPathObject);
	xmlXPathFreeContext(xPathContext); 
	return results;
    
}

+ (NSObject *) representationForNode:(xmlNodePtr)currentNode parent:(NSObject *)aParentRepresentationOrNil {

	IRXMLNode *returnedRepresentation = [[[IRXMLNode alloc] init] autorelease];
	
	NSString * (^fromCString)() = ^ (const char *aCString) {
	
		return [NSString stringWithCString:aCString encoding:NSUTF8StringEncoding];
	
	};
	
	
	if (currentNode->name) {

		returnedRepresentation.name = fromCString(currentNode->name);
	
	}
	
	
	if (currentNode->content && currentNode->type != XML_DOCUMENT_TYPE_NODE) {
	
		BOOL nodeIsText = [returnedRepresentation.name isEqual:@"text"];
		BOOL nodeHasParent = (aParentRepresentationOrNil != nil);
		
		NSString *insertedContents = fromCString(currentNode->content);
	
		if (nodeIsText && nodeHasParent)
		insertedContents = [insertedContents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
				
		returnedRepresentation.content = insertedContents;
	
	}
	
	
	xmlAttr *nodeProperties = currentNode->properties;
	
	if (nodeProperties) {
	
		while (nodeProperties) {
		
			if (nodeProperties->children) {
			
				[returnedRepresentation.attributes setObject:[self representationForNode:nodeProperties->children parent:nil] forKey:fromCString(nodeProperties->name)];
			
			}
						
			nodeProperties = nodeProperties->next;
		
		}
		
	}
	
	
	xmlNodePtr nodeChildren = currentNode->children;
	
	if (nodeChildren) {
	
		while (nodeChildren) {
		
			[returnedRepresentation.children addObject:[self representationForNode:nodeChildren parent:returnedRepresentation]];
		
			nodeChildren = nodeChildren->next;
		
		}
	
	}
	
	return returnedRepresentation;

}

@end










@interface IRXMLNode ()

@property (nonatomic, readwrite, retain) NSMutableDictionary *attributes; 
@property (nonatomic, readwrite, retain) NSMutableArray *children;

@end

@implementation IRXMLNode

@synthesize name, content, attributes, children;

+ (IRXMLNode *) nodeWithName:(NSString *)aName {

	IRXMLNode *returnedNode = [[self alloc] init];
	
	returnedNode.name = aName;
	
	return [returnedNode autorelease];

}

- (id) init {

	self = [super init];
	if (!self) return nil;
	
	self.name = nil;
	self.content = nil;
	self.attributes = [NSMutableDictionary dictionary];
	self.children = [NSMutableArray array];
	
	return self;

}

- (void) dealloc {

	[name release];
	[content release];
	[attributes release];
	[children release];
	
	name = nil;
	content = nil;
	attributes = nil;
	children = nil;
	
	[super dealloc];

}

- (NSString *) description {

	return [NSString stringWithFormat:

	@"\n"	@"Name: %@"
	@"\n"	@"Content: %@"
	@"\n"	@"Attributes: %@"
	@"\n"	@"Children: %@",

		[self.name description], 
		[self.content description], 
		[self.attributes description], 
		[self.children description]
	
	];

}

@end




