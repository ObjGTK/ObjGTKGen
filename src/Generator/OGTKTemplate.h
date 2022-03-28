/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "OGTKLibrary.h"
#import <ObjFW/ObjFW.h>

@interface OGTKTemplate: OFObject

+ (OFDictionary *)
    dictWithReplaceValuesForBuildFilesOfLibrary:(OGTKLibrary *)libraryInfo
                        templateSnippetsFromDir:(OFString *)snippetDir
                                    sourceFiles:(OFString *)sourceFiles;

+ (OFDictionary *)dictWithRenamesForBuildFilesOfLibrary:
    (OGTKLibrary *)libraryInfo;

@end