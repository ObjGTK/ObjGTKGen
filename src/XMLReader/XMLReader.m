//
// XMLReader.m
// Based on Simple XML to NSDictionary Converter by Troy Brant
// Original source here
// http://troybrant.net/blog/2010/09/simple-xml-to-nsdictionary-converter/
//
// Ported to ObjFW by Johannes Brakensiek, 2021
//

#import "XMLReader.h"

OFString *const kXMLReaderTextNodeKey = @"text";
OFString *const kXMLNSGtkCore = @"http://www.gtk.org/introspection/core/1.0";
OFString *const kXMLNSForPrefixC = @"http://www.gtk.org/introspection/c/1.0";
OFString *const kXMLNSForPrefixXml = @"http://www.w3.org/XML/1998/namespace";
OFString *const kXMLNSForPrefixGlib =
    @"http://www.gtk.org/introspection/glib/1.0";
OFString *const kXMLNSForPrefixXmlns = @"http://www.w3.org/2000/xmlns/";

@interface XMLReader (Internal)

- (OFDictionary *)dictionaryForXMLString:(OFString *)string;

@end

@implementation XMLReader

#pragma mark -
#pragma mark Public methods

+ (NSDictionary *)dictionaryForXMLString:(OFString *)string
{
	XMLReader *reader = [[[XMLReader alloc] init] autorelease];
	OFDictionary *rootDictionary = [reader dictionaryForXMLString:string];
	return rootDictionary;
}

#pragma mark -
#pragma mark Parsing

- (void)dealloc
{
	[_dictionaryStack release];
	[_textInProgress release];

	[super dealloc];
}

- (OFDictionary *)dictionaryForXMLString:(OFString *)string
{
	// Clear out any old data
	[_dictionaryStack release];
	[_textInProgress release];
	_dictionaryStack = nil;
	_textInProgress = nil;

	_dictionaryStack = [[OFMutableArray alloc] init];
	_textInProgress = [[OFMutableString alloc] init];

	// Initialize the stack with a fresh dictionary
	[_dictionaryStack addObject:[OFMutableDictionary dictionary]];

	// Parse the XML
	OFXMLParser *parser = [OFXMLParser parser];
	parser.delegate = self;
	[parser parseString:string];

	return [_dictionaryStack objectAtIndex:0];
}

#pragma mark -
#pragma mark OFXMLParserDelegate method

- (void)parser:(OFXMLParser *)parser
    didStartElement:(OFString *)elementName
             prefix:(nullable OFString *)prefix
          namespace:(OFString *)namespace
         attributes:(OFArray *)attributes
{
	// Restore elementName containing the namespace prefix
	elementName = [self reAddPrefixToElement:elementName
	                               namespace:namespace];

	// Get the dictionary for the current level in the stack
	OFMutableDictionary *parentDict = [_dictionaryStack lastObject];

	// Create the child dictionary for the new element, and initialize it
	// with the attributes
	OFMutableDictionary *childDict = [OFMutableDictionary dictionary];
	OFString *attributeName;
	for (OFXMLAttribute *attribute in attributes) {
		attributeName = [self reAddPrefixToAttribute:attribute];
		[childDict setValue:attribute.stringValue forKey:attributeName];
	}

	// If there’s already an item for this key, it means we need to create
	// an array
	id existingValue = [parentDict objectForKey:elementName];
	if (existingValue) {
		OFMutableArray *array = nil;
		if ([existingValue isKindOfClass:[OFMutableArray class]]) {
			// The array exists, so use it
			array = (OFMutableArray *)existingValue;
		} else {
			// Create an array if it doesn’t exist
			array = [OFMutableArray array];
			[array addObject:existingValue];

			// Replace the child dictionary with an array of
			// children dictionaries
			[parentDict setObject:array forKey:elementName];
		}

		// Add the new child dictionary to the array
		[array addObject:childDict];
	} else {
		// No existing value, so update the dictionary
		[parentDict setObject:childDict forKey:elementName];
	}

	// Update the stack
	[_dictionaryStack addObject:childDict];
}

- (OFString *)reAddPrefixToAttribute:(OFXMLAttribute *)attribute
{
	// Prefixes are added for namespace binding
	if (!attribute.namespace)
		return attribute.name;

	OFString *attributeName;

	if ([attribute.namespace isEqual:kXMLNSForPrefixC])
		attributeName =
		    [OFString stringWithFormat:@"c:%@", attribute.name];
	else if ([attribute.namespace isEqual:kXMLNSForPrefixXml])
		attributeName =
		    [OFString stringWithFormat:@"xml:%@", attribute.name];
	else if ([attribute.namespace isEqual:kXMLNSForPrefixGlib])
		attributeName =
		    [OFString stringWithFormat:@"glib:%@", attribute.name];
	else if ([attribute.namespace isEqual:kXMLNSForPrefixXmlns])
		attributeName =
		    [OFString stringWithFormat:@"xmlns:%@", attribute.name];
	else {
		OFLog(@"Unknown namespace %@ for attribute %@",
		    attribute.namespace, attribute.name);
		attributeName = attribute.name;
	}

	return attributeName;
}

- (OFString *)reAddPrefixToElement:(OFString *)elementName
                         namespace:(OFString *)namespace
{
	if (namespace == nil || [namespace isEqual:kXMLNSGtkCore])
		return elementName;

	if ([namespace isEqual:kXMLNSForPrefixC])
		elementName = [OFString stringWithFormat:@"c:%@", elementName];
	else if ([namespace isEqual:kXMLNSForPrefixGlib])
		elementName =
		    [OFString stringWithFormat:@"glib:%@", elementName];
	else {
		OFLog(@"Unknown namespace %@ for element %@", namespace,
		    elementName);
	}

	return elementName;
}

- (void)parser:(OFXMLParser *)parser
    didEndElement:(OFString *)elementName
           prefix:(nullable OFString *)prefix
        namespace:(OFString *)namespace
{
	// Update the parent dict with text info
	OFMutableDictionary *dictInProgress = [_dictionaryStack lastObject];

	// Set the text property
	if ([_textInProgress length] > 0) {
		// Get rid of leading + trailing whitespace
		[dictInProgress setObject:_textInProgress
		                   forKey:kXMLReaderTextNodeKey];

		// Reset the text
		[_textInProgress release];
		_textInProgress = nil;
		_textInProgress = [[OFMutableString alloc] init];
	}

	// Pop the current dict
	[_dictionaryStack removeLastObject];
}

- (void)parser:(OFXMLParser *)parser foundCharacters:(OFString *)string
{
	// Build the text value
	[_textInProgress appendString:string];
}

@end
