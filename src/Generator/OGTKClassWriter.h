/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import <ObjFW/ObjFW.h>

#import "OGTKClass.h"
#import "OGTKLibrary.h"
#import "OGTKMapper.h"
#import "OGTKUtil.h"

/**
 * @brief Functions to write in-memory representations of classes to file as
 * Obj-C source file.
 */
@interface OGTKClassWriter: OFObject
{
	OGTKClass *_classDescription;
	OGTKLibrary *_libraryDescription;
}

/**
 * @brief The class description object which is then
 * used to write out the wrapper strings
 */
@property (retain, nonatomic) OGTKClass *classDescription;

/**
 * @brief The class description object which is then
 * used to write out the wrapper strings
 */
@property (retain, nonatomic) OGTKLibrary *libraryDescription;

/**
 * @brief Reads the text from conf/license.txt and replaces "@@@FILENAME@@@"
 * with fileName.
 * @param fileName The file name to insert into the license content string
 * @return The generated license content string
 */
+ (OFString *)generateLicense:(OFString *)fileName;

/**
 * @brief      Initializes the with class description object which is then
 * used to write out the wrapper strings
 *
 * @param       classDescription        The class description object
 * @param       libraryDescription      The library description object
 *
 * @return     instancetype
 */
- (instancetype)initWithClass:(OGTKClass *)classDescription
                      library:(OGTKLibrary *)libraryDescription;

/**
 * @brief Generates both header and source files for a class based on the class
 * and the library description object given, writes them to outputDir.
 *
 * @param outputDir The directory to write the output to.
 */
- (void)generateFilesInDir:(OFString *)outputDir;

/**
 * @brief Generates header file contents based on the class and library
 * description object given.
 * @return The header file content string
 */
- (OFString *)headerString;

/**
 * @brief Generates source file contents based for the class description object
 * given.
 * @return The source file content string
 */
- (OFString *)sourceString;

/**
 * @brief Generates a list of parameters to pass to an underlying C
 * function.
 * @param params The array of function/method parameters
 * @param throws True to add a parameter for error handling
 * @return The string containing the list of parameters, formatted correctly
 */
- (OFString *)generateCParameterListString:(OFArray OF_GENERIC(
                                               OGTKParameter *) *)params
                           throwsException:(bool)throws;

/**
 * @brief Generates list of parameters to pass to an underlying C function
 * including the call to get a referene to an instance of the class.
 * @param instanceType The Gobj/C instance type
 * @param params An array of parameters to generate the list for
 * @param throws True to add a parameter for error handling
 * @return The string containing the list of parameters, formatted correctly
 */
- (OFString *)generateCParameterListWithInstanceString:(OFString *)instanceType
                                             andParams:
                                                 (OFArray OF_GENERIC(
                                                     OGTKParameter *) *)params
                                       throwsException:(bool)throws;

/**
 * @brief Uses the information description object to return correctly formatted
 * documentation for this method.
 * @param meth The method description object
 * @return The documentation block formatted correctly
 */
- (OFString *)generateDocumentationForMethod:(OGTKMethod *)meth;

@end
