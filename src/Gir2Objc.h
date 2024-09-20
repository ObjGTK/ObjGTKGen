/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2023 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2023 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import <ObjFW/ObjFW.h>

#import "GIR/GIRAPI.h"
#import "GIR/GIRNamespace.h"
#import "Generator/OGTKLibrary.h"
#import "Generator/OGTKMapper.h"

/**
 * @brief Provides functionality to convert GObject Introspection GIR files into
 * Objective-C source code (wrapping C GObject calls and mapping GObject data
 * types to Objective-C data types).
 */
@interface Gir2Objc: OFObject

/**
 * @brief      Parses the girFile XML into the OFDictionary
 *
 * @param      girFile  The GIR file name
 * @param      girDict  The target dictionary
 */
+ (void)parseGirFromFile:(OFString *)girFile intoDictionary:(OFDictionary **)girDict;

/**
 * Iterates through the OFDictionary recursively looking for the first "api" or
 * "repository" key and then attempts to parse that into a GIRAPI object.
 *
 * @param       girDict The parsed GIR XML file represented by this dictionary
 * @returns     The first API found
 */
+ (GIRAPI *)firstAPIFromDictionary:(OFDictionary *)girDict;

/**
 * Parses the girFile XML and then attempts to extract a GIRAPI from the parsed
 * contents.
 * @param       girFile     The file name of the GIR XML file to parse
 * @returns     The first API found
 */
+ (GIRAPI *)firstAPIFromGirFile:(OFString *)girFile;

/**
 * @brief      Generates and maps API description on a library level
 *
 * @param      api   Object describing the GIR API
 *
 * @return     An abstract description of the API, containing mappings able to
 *             generate ObjC files.
 */
+ (OGTKLibrary *)generateLibraryInfoFromAPI:(GIRAPI *)api;

/**
 * @brief      Generates and maps API description on a class level
 * (constructors, functions, methods, properties) and holds them in mapper
 * object specified.
 *
 * @param      ns           The namespace / GObject library
 * @param      libraryInfo  The abstract library information used for generating
 *                          ObjC source files
 * @param      mapper       The mapper holding class definition files
 */
+ (void)generateClassInfoFromNamespace:(GIRNamespace *)ns
                            forLibrary:(OGTKLibrary *)libraryInfo
                            intoMapper:(OGTKMapper *)mapper;

@end
