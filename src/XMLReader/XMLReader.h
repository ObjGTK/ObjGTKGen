//
// XMLReader.h
// Based on Simple XML to NSDictionary Converter by Troy Brant
// Original source here
// http://troybrant.net/blog/2010/09/simple-xml-to-nsdictionary-converter/
//

#import <ObjFW/ObjFW.h>

@interface XMLReader: OFObject <OFXMLParserDelegate>
{
	OFMutableArray *_dictionaryStack;
	OFMutableString *_textInProgress;
}

+ (OFDictionary *)dictionaryForXMLString:(OFString *)string;

@end
