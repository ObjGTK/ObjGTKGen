/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2023 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2023 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

@class OGTKLibrary;
@class OGTKMapper;
@class OGTKClass;

/**
 * Bundles methods to copy and generate source files for a specific library.
 */
@interface OGTKLibraryWriter: OFObject
{
	OGTKLibrary *_libraryDescription;
	OGTKMapper *_mapper;
	OFString *_outputDir;
}

@property (retain, nonatomic) OGTKLibrary *libraryDescription;
@property (retain, nonatomic) OGTKMapper *mapper;
@property (copy, nonatomic) OFString *outputDir;
@property (readonly) OFString *sourceOutputDir;

/**
 * @brief      Copies files and directories recursively and applies a
 * method/selector on its contents using a replace and a rename dictionary.
 *
 * @param      sourceDir    The source directory
 * @param      destDir      The destination directory
 * @param      methodName   A method name of this class to apply to the
 *                          contents of the dir
 * @param      replaceDict  Which content of the files to replace (replace keys
 *                          by values)
 * @param      renameDict   Which file names to change (rename keys to values)
 */
+ (void)copyFilesFromDir:(OFString *)sourceDir
                            toDir:(OFString *)destDir
    applyOnFileContentMethodNamed:(OFString *)methodName
                 usingReplaceDict:(OFDictionary *)replaceDict
                  usingRenameDict:(OFDictionary *)renameDict;

/**
 * @brief      Copies files and directories recursively.
 *
 * @param      sourceDir  The source directory
 * @param      destDir    The destination directory
 */
+ (void)copyFilesFromDir:(OFString *)sourceDir toDir:(OFString *)destDir;

/**
 * @brief      Replaces strings within a string using a dictionary.
 *
 * @param      content      The content string
 * @param      replaceDict  The replace dictionary (replace keys by values)
 */
+ (OFString *)forFileContent:(OFString *)content
                replaceUsing:(OFDictionary *)replaceDict;

/**
 * @brief      Initializes the with library description object which is then
 * used to write out the wrapper strings to files in outputDir. Depending data
 * is collected from the mapper.
 *
 * @param       libraryDescription     The library description object
 * @param       sharedMapper           The shared mapper which holds all
 * information
 * @param       outputDir             The directory the generated lib should be
 * saved to
 *
 * @return     instancetype
 */
- (instancetype)initWithLibrary:(OGTKLibrary *)libraryDescription
                         mapper:(OGTKMapper *)sharedMapper
                      outputDir:(OFString *)outputDir;

/**
 * @brief      Generates the actual output of this generator: For each class of
 * the library held within memory (passed by using the mapper object) it writes
 * its class definition to the specified output directory (see initializer).
 */
- (void)writeClassFiles;

/**
 * @brief      Adds manually written source files to previously genereted
 * generic library definitions (mappings/bindings).
 *
 * @param      baseClassPath  The path where to look for the library source
 *                            additions
 */
- (void)writeLibraryAdditionsWithSourcesFromDir:(OFString *)baseClassPath;

/**
 * @brief      Generates the umbrella header file for the lib named and saves it
 * to output dir for this library.
 *
 * @param      additionalHeaderDir  The directory to look into for additional
 * headers
 */
- (void)generateUmbrellaHeaderFileWithAdditionalHeadersFromDir:
    (OFString *)additionalHeaderDir;

- (void)templateAndCopyBuildFilesFromDir:(OFString *)templateDir
                    usingSnippetsFromDir:(OFString *)templateSnippetsDir;

/**
 * @brief      Looks for files inside a directory having a specific file
 * extensions and returns a sorted and formtted file name list as a string.
 *
 * @param      dirPath        The directory in which to look for the files.
 * @param      format         A string format instruction using which
 *                            the list of file names is concatenated, f.e.
 *                            '@"#import \"%@\"\n"' for a umbrella header
 * file.
 * @param      fileExtension  The file extension to look for. Only files
 * having this extensions will be listed.
 *
 * @return     A list of matching file names within one string.
 */
- (OFString *)stringForFilesInDir:(OFString *)dirPath
                     addingFormat:(OFConstantString *)format
          lookingForFileExtension:(OFString *)fileExtension;

@end
