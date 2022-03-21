/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

#import "GIR/GIRAPI.h"
#import "GIR/GIRNamespace.h"
#import "Generator/OGTKLibrary.h"
#import "Generator/OGTKMapper.h"

/**
 * Provides functionality to convert GObject Introspection GIR files into ObjGTK
 * source code
 */
@interface Gir2Objc: OFObject

/**
 * Parses the girFile XML into the OFDictionary
 */
+ (void)parseGirFromFile:(OFString *)girFile
          intoDictionary:(OFDictionary **)girDict;

/**
 * Recurses through the OFDictionary looking for the first "api" or "repository"
 * key and then attempts to parse that into a GIRAPI. If no key is found nil is
 * returned.
 */
+ (GIRAPI *)firstAPIFromDictionary:(OFDictionary *)girDict;

/**
 * Parses the girFile XML and then attempts to extract a GIRAPI from the parsed
 * contents. If the GIR is successfully parsed, but no valid data is found, nil
 * is returned.
 */
+ (GIRAPI *)firstAPIFromGirFile:(OFString *)girFile;

+ (OGTKLibrary *)generateLibraryInfoFromAPI:(GIRAPI *)api;

/**
 * Generates class information from the GIR Namespace level
 */
+ (void)generateClassInfoFromNamespace:(GIRNamespace *)ns
                            forLibrary:(OGTKLibrary *)libraryInfo
                            intoMapper:(OGTKMapper *)mapper;

@end
