/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import <ObjFW/ObjFW.h>

@class OGTKLibrary;
@class OGTKMapper;

@interface OGTKFileOperation: OFObject

+ (void)copyFilesFromDir:(OFString *)sourceDir
                            toDir:(OFString *)destDir
    applyOnFileContentMethodNamed:(OFString *)methodName
                 usingReplaceDict:(OFDictionary *)replaceDict
                  usingRenameDict:(OFDictionary *)renameDict;

+ (void)copyFilesFromDir:(OFString *)sourceDir toDir:(OFString *)destDir;

+ (OFString *)forFileContent:(OFString *)content
                replaceUsing:(OFDictionary *)replaceDict;

+ (void)writeClassFilesForLibrary:(OGTKLibrary *)libraryInfo
                            toDir:(OFString *)outputDir
    getClassDefinitionsFromMapper:(OGTKMapper *)mapper;

+ (void)writeLibraryAdditionsFor:(OGTKLibrary *)libraryInfo
                            toDir:(OFString *)outputDir
    getClassDefinitionsFromMapper:(OGTKMapper *)mapper
     readAdditionalSourcesFromDir:(OFString *)baseClassPath;

@end
