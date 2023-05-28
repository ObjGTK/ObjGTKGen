/*
 * SPDX-FileCopyrightText: 2021-2023 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2021-2023 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "OGTKLibrary.h"
#import <ObjFW/ObjFW.h>
@class OGTKMapper;

/**
 * @brief Handles template contents for the ObjFW buildsys. Generates autoconf
 * and buildsys content strings that need to be replaced/changed within the
 * build files that are meant the handle build process of the generated library
 * source files.
 */
@interface OGTKTemplate: OFObject
{
	OFString *_snippetDir;
	OGTKMapper *_sharedMapper;
}

/**
 * Directory in which to look for the template files
 */
@property (copy, nonatomic) OFString *snippetDir;

/**
 * Mapper object holding the class definition files for a library
 */
@property (retain, nonatomic) OGTKMapper *sharedMapper;

- (instancetype)init OF_UNAVAILABLE;

/**
 * @brief      Initializes
 *
 * @param      snippetDir    The directory in which to look for template files
 * @param      sharedMapper  The mapper object holding the class definition
 *                           files for a library
 */
- (instancetype)initWithSnippetDir:(OFString *)snippetDir
                      sharedMapper:(OGTKMapper *)sharedMapper;

/**
 * @brief      Returns a dictionary that holds keys that need to be replaced
 * by values within the autoconf/buildsys files.
 *
 * @param      libraryInfo  The library information object describing the
 * library
 * @param      sourceFiles  A list of source files (to compile with buildsys) as
 *                          a string
 *
 * @return     The dictionary holding strings as keys that need to be replaced
 *             by values within the autoconf/buildsys files.
 */
- (OFDictionary *)
    dictWithReplaceValuesForBuildFilesOfLibrary:(OGTKLibrary *)libraryInfo
                                    sourceFiles:(OFString *)sourceFiles;

/**
 * @brief      Returns a dictionary that holds keys of file names that need to
 * be renamed to values.
 *
 * @param      libraryInfo The library information object describing the library
 *
 * @return     The dictionary holding file names as keys that need to be renamed
 *             to values.
 */
- (OFDictionary *)dictWithRenamesForBuildFilesOfLibrary:
    (OGTKLibrary *)libraryInfo;

@end