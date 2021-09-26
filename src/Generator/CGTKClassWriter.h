/*
 * CGTKClassWriter.h
 * This file is part of CoreGTKGen
 *
 * Copyright (C) 2017 - Tyler Burton
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 */

/*
 * Objective-C imports
 */
#import <ObjFW/ObjFW.h>

#import "CGTKUtil.h"
#import "CGTKClass.h"

/**
 * Functions to write in memory Class representation to file as CoreGTK source
 */
@interface CGTKClassWriter : OFObject
{

}

/**
 * Generate both header and source files based on class and save them in outputDir
 */
+(void)generateFilesForClass:(CGTKClass *) cgtkClass inDir:(OFString *) outputDir;

/**
 * Generate header file contents based on class
 */
+(OFString *)headerStringFor:(CGTKClass *) cgtkClass;

/**
 * Generate source file contents based on class
 */
+(OFString *)sourceStringFor:(CGTKClass *) cgtkClass;

/**
 * Generate list of paramters to pass to underlying C function
 */
+(OFString *)generateCParameterListString:(OFArray *) params;
+(OFString *)generateCParameterListWithInstanceString:(OFString *)instanceType andParams:(OFArray *) params;

/**
 * Reads the text from conf/license.txt and replaces "@@@FILENAME@@@" with fileName
 */
+(OFString *)generateLicense:(OFString *)fileName;

/**
 * Uses the information in the method to return documentation for the method
 */
+(OFString *)generateDocumentationForMethod:(CGTKMethod *)meth;

@end
