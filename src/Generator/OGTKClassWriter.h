/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import <ObjFW/ObjFW.h>

#import "OGTKClass.h"
#import "OGTKLibrary.h"
#import "OGTKMapper.h"
#import "OGTKUtil.h"

/**
 * Functions to write in memory Class representation to file as ObjGTK source
 */
@interface OGTKClassWriter: OFObject

/**
 * Generate both header and source files based on class and save them in
 * outputDir
 */
+ (void)generateFilesForClass:(OGTKClass *)cgtkClass
                        inDir:(OFString *)outputDir
                   forLibrary:(OGTKLibrary *)library;

/**
 * Generate header file contents based on class
 */
+ (OFString *)headerStringFor:(OGTKClass *)cgtkClass
                      library:(OGTKLibrary *)library;

/**
 * Generate source file contents based on class
 */
+ (OFString *)sourceStringFor:(OGTKClass *)cgtkClass;

/**
 * Generate list of paramters to pass to underlying C function
 */
+ (OFString *)generateCParameterListString:(OFArray *)params;
+ (OFString *)generateCParameterListWithInstanceString:(OFString *)instanceType
                                             andParams:(OFArray *)params;

/**
 * Reads the text from conf/license.txt and replaces "@@@FILENAME@@@" with
 * fileName
 */
+ (OFString *)generateLicense:(OFString *)fileName;

/**
 * Uses the information in the method to return documentation for the method
 */
+ (OFString *)generateDocumentationForMethod:(OGTKMethod *)meth;

@end
