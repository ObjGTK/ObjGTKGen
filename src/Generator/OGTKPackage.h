#import "OGTKLibrary.h"
#import <ObjFW/ObjFW.h>

@interface OGTKPackage: OFObject

+ (OFDictionary *)
    dictWithReplaceValuesForBuildFilesOfLibrary:(OGTKLibrary *)libraryInfo
                        templateSnippetsFromDir:(OFString *)snippetDir;

@end