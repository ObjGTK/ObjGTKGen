//
// XMLReader.m
// Based on Simple XML to NSDictionary Converter by Troy Brant
// Original source here http://troybrant.net/blog/2010/09/simple-xml-to-nsdictionary-converter/
//
// Ported to ObjFW by Johannes Brakensiek, 2021
//

#import "XMLReader.h"

OFString* const kXMLReaderTextNodeKey = @"text";
OFString* const kXMLNSForPrefixC = @"http://www.gtk.org/introspection/c/1.0";
OFString* const kXMLNSForPrefixXml = @"http://www.w3.org/XML/1998/namespace";
OFString* const kXMLNSForPrefixGlib = @"http://www.gtk.org/introspection/glib/1.0";
OFString* const kXMLNSForPrefixXmlns = @"http://www.w3.org/2000/xmlns/";

@interface XMLReader (Internal)

- (OFDictionary*)dictionaryForXMLString:(OFString*)string;

@end

@implementation XMLReader

#pragma mark -
#pragma mark Public methods

+ (NSDictionary*)dictionaryForXMLString:(OFString*)string
{
    XMLReader* reader = [[XMLReader alloc] init];
    OFDictionary* rootDictionary = [reader dictionaryForXMLString:string];
    [reader release];
    return rootDictionary;
}

#pragma mark -
#pragma mark Parsing

- (void)dealloc
{
    [dictionaryStack release];
    [textInProgress release];
    [super dealloc];
}

- (OFDictionary*)dictionaryForXMLString:(OFString*)string
{
    // Clear out any old data
    [dictionaryStack release];
    [textInProgress release];

    dictionaryStack = [[OFMutableArray alloc] init];
    textInProgress = [[OFMutableString alloc] init];

    // Initialize the stack with a fresh dictionary
    [dictionaryStack addObject:[OFMutableDictionary dictionary]];

    // Parse the XML
    OFXMLParser* parser = [[OFXMLParser alloc] init];
    parser.delegate = self;
    [parser parseString:string];

    OFDictionary* resultDict = [dictionaryStack objectAtIndex:0];
    return resultDict;
}

#pragma mark -
#pragma mark OFXMLParserDelegate method

- (void)parser:(OFXMLParser*)parser didStartElement:(OFString*)elementName prefix:(nullable OFString*)prefix namespace:(OFString*)namespace attributes:(OFArray*)attributes
{
    // Get the dictionary for the current level in the stack
    OFMutableDictionary* parentDict = [dictionaryStack lastObject];

    // Create the child dictionary for the new element, and initilaize it with the attributes
    OFMutableDictionary* childDict = [OFMutableDictionary dictionary];
    OFString* attributeName;
    for (OFXMLAttribute* attribute in attributes) {
        attributeName = [self reAddPrefixToAttribute:attribute];
        [childDict setValue:attribute.stringValue
                     forKey:attributeName];
    }

    // If there’s already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue) {
        OFMutableArray* array = nil;
        if ([existingValue isKindOfClass:[OFMutableArray class]]) {
            // The array exists, so use it
            array = (OFMutableArray*)existingValue;
        } else {
            // Create an array if it doesn’t exist
            array = [OFMutableArray array];
            [array addObject:existingValue];

            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:elementName];
        }

        // Add the new child dictionary to the array
        [array addObject:childDict];
    } else {
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }

    // Update the stack
    [dictionaryStack addObject:childDict];
}

- (OFString*)reAddPrefixToAttribute:(OFXMLAttribute*)attribute
{
    // Prefixes are added for namespace binding
    if (!attribute.namespace)
        return [OFString stringWithString:attribute.name];

    OFString* attributeName;

    if ([attribute.namespace isEqual:kXMLNSForPrefixC])
        attributeName = [OFString stringWithFormat:@"c:%@", attribute.name];
    else if ([attribute.namespace isEqual:kXMLNSForPrefixXml])
        attributeName = [OFString stringWithFormat:@"xml:%@", attribute.name];
    else if ([attribute.namespace isEqual:kXMLNSForPrefixGlib])
        attributeName = [OFString stringWithFormat:@"glib:%@", attribute.name];
    else if ([attribute.namespace isEqual:kXMLNSForPrefixXmlns])
        attributeName = [OFString stringWithFormat:@"xmlns:%@", attribute.name];
    else {
        OFLog(@"Unknown namespace %@ for attribute %@", attribute.namespace, attribute.name);
        attributeName = [OFString stringWithString:attribute.name];
    }

    return attributeName;
}

- (void)parser:(OFXMLParser*)parser didEndElement:(OFString*)elementName prefix:(nullable OFString*)prefix namespace:(OFString*)namespace
{
    // Update the parent dict with text info
    OFMutableDictionary* dictInProgress = [dictionaryStack lastObject];

    // Set the text property
    if ([textInProgress length] > 0) {
        // Get rid of leading + trailing whitespace
        [dictInProgress setObject:textInProgress forKey:kXMLReaderTextNodeKey];

        // Reset the text
        [textInProgress release];
        textInProgress = [[OFMutableString alloc] init];
    }

    // Pop the current dict
    [dictionaryStack removeLastObject];
}

- (void)parser:(OFXMLParser*)parser foundCharacters:(OFString*)string
{
    // Build the text value
    [textInProgress appendString:string];
}

@end
