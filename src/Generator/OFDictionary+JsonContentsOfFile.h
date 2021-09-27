#import <ObjFW/ObjFW.h>

@interface OFDictionary (JsonContentsOfFile)

- (instancetype)initWithContentsOfFile:(OFString*)filePath;

@end