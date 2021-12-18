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

#import "Gir2Objc.h"
#include "Exceptions/OGTKDataProcessingNotImplementedException.h"
#include "GIR/GIRNamespace.h"
#include <ObjFW/OFInvalidArgumentException.h>

#import "Generator/OGTKClassWriter.h"
#import "Generator/OGTKLibrary.h"
#import "Generator/OGTKMapper.h"
#import "Generator/OGTKParameter.h"
#import "Generator/OGTKUtil.h"

#import "Exceptions/OGTKNoGIRAPIException.h"
#import "Exceptions/OGTKNoGIRDictException.h"

#import "XMLReader/XMLReader.h"

@implementation Gir2Objc

+ (void)parseGirFromFile:(OFString *)girFile
          intoDictionary:(OFDictionary **)girDict;
{
	*girDict = nil;

	OFString *girContents =
	    [[[OFString alloc] initWithContentsOfFile:girFile] autorelease];

	if (girContents == nil) {
		@throw [OFReadFailedException exceptionWithObject:girFile
		                                  requestedLength:0
		                                            errNo:0];
	}

	@try {
		// Parse the XML into a dictionary
		*girDict = [XMLReader dictionaryForXMLString:girContents];
	} @catch (id exception) {
		// On error, if a dictionary was still created, clean it up
		// before returning
		if (*girDict != nil) {
			[*girDict release];
		}

		@throw exception;
	}
}

+ (GIRAPI *)firstAPIFromDictionary:(OFDictionary *)girDict
{
	if (girDict == nil)
		@throw [OGTKNoGIRDictException exception];

	for (OFString *key in girDict) {
		id value = [girDict objectForKey:key];

		if ([key isEqual:@"api"] || [key isEqual:@"repository"]) {
			return [[[GIRAPI alloc] initWithDictionary:value]
			    autorelease];
		} else if ([value isKindOfClass:[OFDictionary class]]) {
			return [Gir2Objc firstAPIFromDictionary:value];
		}
	}

	return nil;
}

+ (GIRAPI *)firstAPIFromGirFile:(OFString *)girFile
{
	OFDictionary *girDict = nil;

	[Gir2Objc parseGirFromFile:girFile intoDictionary:&girDict];

	return [Gir2Objc firstAPIFromDictionary:girDict];
}

+ (void)generateClassFilesFromAPI:(GIRAPI *)api
{
	OFArray *namespaces = api.namespaces;

	if (api == nil || namespaces == nil)
		@throw [OGTKNoGIRAPIException exception];

	OGTKMapper *sharedMapper = [OGTKMapper sharedMapper];

	// Map library information from API
	OGTKLibrary *libraryInfo = [[[OGTKLibrary alloc] init] autorelease];
	libraryInfo.version = api.version;
	libraryInfo.packageName = api.package;
	for (OFString *include in api.cInclude) {
		[libraryInfo addCInclude:include];
	}

	for (OFString *dependency in api.include) {
		[libraryInfo addDependency:dependency];
	}

	if (namespaces.count > 1)
		@throw [OGTKDataProcessingNotImplementedException
		    exceptionWithDescription:
		        @"Found more than one namespace within an GIR API. "
		        @"That's unexpected and not implemented yet. Please "
		        @"contact the maintainer."];

	GIRNamespace *ns = namespaces.firstObject;

	// Map library information from namespace
	libraryInfo.girName = ns.name;
	[libraryInfo addSharedLibrariesAsString:ns.sharedLibrary];
	libraryInfo.cNSIdentifierPrefix = ns.cIdentifierPrefixes;
	libraryInfo.cNSSymbolPrefix = ns.cSymbolPrefixes;

	// TODO: Move parts concerning library into its own method (0.), then
	// proceed with 1.

	// 1. Load config from file:
	//	- excluded classes
	//	- custom library name
	// 2. Add that information to libraryInfo

	[sharedMapper addLibrary:libraryInfo];

	// 3. Pass librarInfo to generateClassInfoFromNamespace:
	//		let that method exclude excluded classes

	[Gir2Objc generateClassInfoFromNamespace:ns];

	OFMutableDictionary *classesDict =
	    [sharedMapper objcTypeToClassMapping];

	// 4. Create library dir
	// 5. Copy makefiles (based on libraryInfo)
	// 6. Copy BaseClasses (based on libraryInfo)
	// 		- remove that part from ObjGTKGen

	[Gir2Objc writeClassFilesFromClassesDict:classesDict];
}

+ (void)generateClassInfoFromNamespace:(GIRNamespace *)ns
{
	if (ns == nil)
		@throw [OGTKNoGIRAPIException exception];

	OFLog(@"Namespace name: %@", ns.name);
	OFLog(@"C symbol prefix: %@", ns.cSymbolPrefixes);
	OFLog(@"C identifier prefix: %@", ns.cIdentifierPrefixes);

	OGTKMapper *sharedMapper = [OGTKMapper sharedMapper];

	for (GIRClass *girClass in ns.classes) {
		@autoreleasepool {
			OGTKClass *objCClass =
			    [[[OGTKClass alloc] init] autorelease];

			[Gir2Objc mapGIRClass:girClass
			          toObjCClass:objCClass
			       usingNamespace:ns];

			@try {
				[sharedMapper addClass:objCClass];
			} @catch (id e) {
				OFLog(@"Warning: Cannot add type %@ to mapper. "
				      @"Exception %@, description: %@"
				      @"Class definition may be incorrect. "
				      @"Skipping…",
				    objCClass.cName, [e class],
				    [e description]);
				[sharedMapper removeClass:objCClass];
			}
		}
	}

	// Set correct class names for parent classes
	OFMutableDictionary *classesDict = sharedMapper.objcTypeToClassMapping;
	OFMutableArray *classesToRemove = [[OFMutableArray alloc] init];

	for (OFString *className in classesDict) {
		OGTKClass *currentClass = [classesDict objectForKey:className];

		if (currentClass.cParentType == nil) {
			@try {
				OFString *cParentType = [OGTKMapper
				    getCTypeFromName:currentClass.parentName];

				[currentClass setCParentType:cParentType];
			} @catch (id e) {
				OFLog(@"Could not get c type for parent of %@, "
				      @"exception %@. "
				      @"Skipping…",
				    currentClass.cName, [e class]);
				[classesToRemove addObject:currentClass];
			}
		}
	}

	for (OGTKClass *currentClass in classesToRemove)
		[sharedMapper removeClass:currentClass];
	[classesToRemove release];

	// Calculate dependencies for each class
	[sharedMapper determineDependencies];

	// Set flags for fast necessary forward class definitions.
	[sharedMapper detectAndMarkCircularDependencies];

	// Informations is collected
}

+ (void)writeClassFilesFromClassesDict:(OFMutableDictionary *)classesDict
{
	OFString *outputDir = [OGTKUtil globalConfigValueFor:@"outputDir"];
	OFString *baseClassPath =
	    [OGTKUtil globalConfigValueFor:@"baseClassDir"];

	// Write the umbrella header file for the lib
	[OGTKClassWriter generateUmbrellaHeaderFileForClasses:classesDict
	                                                inDir:outputDir
	                                      forLibraryNamed:@"ObjGTK"
	                         readAdditionalHeadersFromDir:baseClassPath];

	// Write the classes
	for (OFString *className in classesDict) {
		[OGTKClassWriter
		    generateFilesForClass:[classesDict objectForKey:className]
		                    inDir:outputDir];
	}
}

+ (void)mapGIRClass:(GIRClass *)girClass
        toObjCClass:(OGTKClass *)objCClass
     usingNamespace:(GIRNamespace *)ns
{
	// Set basic class properties
	[objCClass setCName:girClass.name];
	[objCClass setCType:girClass.cType];
	[objCClass setDocumentation:girClass.doc.docText];

	// Set parent name
	[objCClass setParentName:girClass.parent];

	// Try to set parent c type
	// First try to get information from a <field> node.
	// Otherwise we need to get the c type from the mapper
	// later
	OFArray *classFields = girClass.fields;
	for (GIRField *field in classFields) {
		if ([field.name isEqual:@"parent_class"] ||
		    [field.name isEqual:@"parent_instance"]) {
			[objCClass setCParentType:field.type.cType];
		}
	}

	[objCClass setCSymbolPrefix:girClass.cSymbolPrefix];
	[objCClass setCNSIdentifierPrefix:ns.cIdentifierPrefixes];
	[objCClass setCNSSymbolPrefix:ns.cSymbolPrefixes];

	// Set constructors
	[Gir2Objc addMappedGIRMethods:girClass.constructors
	                  toObjCClass:objCClass
	                usingSelector:@selector(addConstructor:)];

	// Set functions
	[Gir2Objc addMappedGIRMethods:girClass.functions
	                  toObjCClass:objCClass
	                usingSelector:@selector(addFunction:)];

	// Set methods
	[Gir2Objc addMappedGIRMethods:girClass.methods
	                  toObjCClass:objCClass
	                usingSelector:@selector(addMethod:)];
}

+ (void)addMappedGIRMethods:(OFMutableArray OF_GENERIC(
                                id<GIRMethodMapping>) *)girMethodArray
                toObjCClass:(OGTKClass *)objCClass
              usingSelector:(SEL)addMethodSelector
{
	// Set constructors
	for (id<GIRMethodMapping> girMethod in girMethodArray) {
		bool foundVarArgs = false;

		// First need to check for varargs in list of
		// parameters
		for (GIRParameter *param in girMethod.parameters) {
			if (param.varargs != nil) {
				foundVarArgs = true;
				break;
			}
		}

		// Don't handle VarArgs methods
		if (foundVarArgs)
			continue;

		OGTKMethod *objcMethod = [[OGTKMethod alloc] init];

		[objcMethod setName:girMethod.name];
		[objcMethod setCIdentifier:girMethod.cIdentifier];
		objcMethod.documentation = girMethod.doc.docText;

		// Set return type
		if (girMethod.returnValue.type == nil &&
		    girMethod.returnValue.array != nil) {
			[objcMethod
			    setCReturnType:girMethod.returnValue.array.cType];
		} else {
			[objcMethod
			    setCReturnType:girMethod.returnValue.type.cType];
		}

		// Set return type documentation
		objcMethod.returnValueDocumentation =
		    girMethod.returnValue.doc.docText;

		// Set if throws GError
		[objcMethod setThrows:girMethod.throws];

		// Set parameters
		OFMutableArray *paramArray = [[OFMutableArray alloc] init];

		for (GIRParameter *param in girMethod.parameters) {
			OGTKParameter *objcParam = [[OGTKParameter alloc] init];
			objcParam.documentation = param.doc.docText;

			if (param.type == nil && param.array != nil) {
				[objcParam setCType:param.array.cType];
			} else {
				[objcParam setCType:param.type.cType];
			}

			[objcParam setCName:param.name];
			[paramArray addObject:objcParam];
			[objcParam release];
		}

		[objcMethod setParameters:paramArray];
		[paramArray release];

		// Add method to class
		[objCClass performSelector:addMethodSelector
		                withObject:objcMethod];
		[objcMethod release];
	}
}

@end
