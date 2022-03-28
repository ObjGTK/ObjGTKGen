/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import <ObjFW/ObjFW.h>

@class OGTKLibrary;
@class OGTKMapper;
@class OGTKClass;

@interface OGTKLibraryWriter: OFObject

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

/**
 * @brief Generates the umbrella header file for the lib named and saves it in
 * outputDir. Assumes that keys of the dict passed are ObjC class names
 */
+ (void)generateUmbrellaHeaderFileForClasses:
            (OFDictionary OF_GENERIC(OFString *, OGTKClass *) *)objCClassesDict
                                       inDir:(OFString *)outputDir
                                  forLibrary:(OGTKLibrary *)libraryInfo
                readAdditionalHeadersFromDir:(OFString *)additionalHeaderDir;

+ (OFString *)stringForFilesInDir:(OFString *)dirPath
                     addingFormat:(OFConstantString *)format
          lookingForFileExtension:(OFString *)fileExtension;

@end
