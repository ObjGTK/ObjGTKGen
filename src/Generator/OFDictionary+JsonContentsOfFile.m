

#import "OFDictionary+JsonContentsOfFile.h"

@implementation OFDictionary (JsonContentsOfFile)

- (instancetype)initWithContentsOfFile:(OFString*)filePath
{
    id object =
        [[OFString stringWithContentsOfFile:filePath] objectByParsingJSON];
    if (![object isKindOfClass:[OFDictionary class]])
        @throw [OFInvalidJSONException
            exceptionWithString:@"JSON file does not contain a dictionary."
                           line:0];

    self = [self initWithDictionary:object];
    return self;
}

@end