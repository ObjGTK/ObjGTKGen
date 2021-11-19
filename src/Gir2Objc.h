/*
 * Gir2Objc.h
 * This file is part of ObjGTKGen
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
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 */

#import <ObjFW/ObjFW.h>

#import "Generator/OGTKClassWriter.h"
#import "Generator/OGTKMapper.h"
#import "Generator/OGTKParameter.h"
#import "Generator/OGTKUtil.h"

#import "GIR/GIRApi.h"
#import "GIR/GIRNamespace.h"

#import "Exceptions/OGTKNoGIRAPIException.h"
#import "Exceptions/OGTKNoGIRDictException.h"

#import "XMLReader/XMLReader.h"

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
 * key and then attempts to parse that into a GIRApi. If no key is found nil is
 * returned.
 */
+ (GIRApi *)firstApiFromDictionary:(OFDictionary *)girDict;

/**
 * Parses the girFile XML and then attempts to extract a GIRApi from the parsed
 * contents. If the GIR is successfully parsed, but no valid data is found, nil
 * is returned.
 */
+ (GIRApi *)firstApiFromGirFile:(OFString *)girFile;

/**
 * Generates ObjGTK source from the GIR API level
 */
+ (void)generateClassFilesFromApi:(GIRApi *)api;

/**
 * Generates ObjGTK source from the GIR Namespace level
 */
+ (void)generateClassFilesFromNamespace:(GIRNamespace *)ns;

@end
