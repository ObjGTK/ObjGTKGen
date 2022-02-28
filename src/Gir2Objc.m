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

#import "Generator/OGTKClassWriter.h"
#import "Generator/OGTKFileOperation.h"
#import "Generator/OGTKParameter.h"
#import "Generator/OGTKUtil.h"

#import "GIR/GIRInclude.h"

#import "Exceptions/OGTKDataProcessingNotImplementedException.h"
#import "Exceptions/OGTKIncorrectConfigException.h"
#import "Exceptions/OGTKNoGIRAPIException.h"
#import "Exceptions/OGTKNoGIRDictException.h"

#import "XMLReader/XMLReader.h"

@interface Gir2Objc()

+ (OFString *)firstOfKommaSeparatedElements:(OFString *)elementString;

+ (void)mapGIRClass:(GIRClass *)girClass
        toObjCClass:(OGTKClass *)objCClass
     usingNamespace:(GIRNamespace *)ns;
     
+ (void)addMappedGIRMethods:(OFMutableArray OF_GENERIC(
                                id<GIRMethodMapping>) *)girMethodArray
                toObjCClass:(OGTKClass *)objCClass
              usingSelector:(SEL)addMethodSelector;

@end


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
			return [self firstAPIFromDictionary:value];
		}
	}

	return nil;
}

+ (GIRAPI *)firstAPIFromGirFile:(OFString *)girFile
{
	OFDictionary *girDict = nil;

	[self parseGirFromFile:girFile intoDictionary:&girDict];

	return [self firstAPIFromDictionary:girDict];
}

+ (OGTKLibrary *)generateLibraryInfoFromAPI:(GIRAPI *)api
                                 intoMapper:(OGTKMapper *)mapper
{
	OFArray *namespaces = api.namespaces;

	if (api == nil || namespaces == nil)
		@throw [OGTKNoGIRAPIException exception];

	// Map library information from API
	OGTKLibrary *libraryInfo = [[[OGTKLibrary alloc] init] autorelease];
	libraryInfo.packageName = api.package;

	for (GIRInclude *include in api.cInclude) {
		[libraryInfo addCInclude:include];
	}

	for (GIRInclude *dependency in api.include) {
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
	libraryInfo.namespace = ns.name;
	libraryInfo.version = ns.version;
	[libraryInfo addSharedLibrariesAsString:ns.sharedLibrary];
	libraryInfo.cNSIdentifierPrefix =
	    [self firstOfKommaSeparatedElements:ns.cIdentifierPrefixes];
	libraryInfo.cNSSymbolPrefix =
	    [self firstOfKommaSeparatedElements:ns.cSymbolPrefixes];

	OFString *libraryIdentifier = libraryInfo.identifier;

	// Load additional configuration provided manually by config file
	OFDictionary *libraryConfig =
	    [OGTKUtil libraryConfigFor:libraryIdentifier];

	if ([libraryConfig valueForKey:@"customName"] != nil)
		libraryInfo.name = [libraryConfig valueForKey:@"customName"];

	if ([libraryConfig valueForKey:@"excludeClasses"] != nil) {
		OFArray *excludeClasses =
		    [libraryConfig valueForKey:@"excludeClasses"];
		libraryInfo.excludeClasses =
		    [OFSet setWithArray:excludeClasses];
	}

	[mapper addLibrary:libraryInfo];

	[self generateClassInfoFromNamespace:ns
	                          forLibrary:libraryInfo
	                          intoMapper:mapper];

	return libraryInfo;
}

+ (OFString *)firstOfKommaSeparatedElements:(OFString *)elementString
{
	return [[elementString componentsSeparatedByString:@","] firstObject];
}

+ (void)writeLibraryAdditionsFor:(OGTKLibrary *)libraryInfo
                            toDir:(OFString *)outputDir
    getClassDefinitionsFromMapper:(OGTKMapper *)mapper
     readAdditionalSourcesFromDir:(OFString *)baseClassPath
{
	OFMutableDictionary *classesDict = mapper.objcTypeToClassMapping;

	if (baseClassPath == nil || outputDir == nil)
		@throw [OGTKIncorrectConfigException exception];

	OFString *libraryOutputDir =
	    [[outputDir stringByAppendingPathComponent:libraryInfo.name]
	        stringByAppendingPathComponent:@"src"];

	// Write the umbrella header file for the lib
	[OGTKClassWriter generateUmbrellaHeaderFileForClasses:classesDict
	                                                inDir:libraryOutputDir
	                                           forLibrary:libraryInfo
	                         readAdditionalHeadersFromDir:baseClassPath];

	OFLog(@"Attempting to copy base class files specific for library %@...",
	    libraryInfo.name);
	[OGTKFileOperation
	    copyFilesFromDir:[baseClassPath
	                         stringByAppendingPathComponent:libraryInfo.identifier]
	               toDir:libraryOutputDir];
}

+ (void)generateClassInfoFromNamespace:(GIRNamespace *)ns
                            forLibrary:(OGTKLibrary *)libraryInfo
                            intoMapper:(OGTKMapper *)mapper
{
	if (ns == nil)
		@throw [OGTKNoGIRAPIException exception];

	OFLog(@"Namespace name: %@", ns.name);
	OFLog(@"C symbol prefix: %@", ns.cSymbolPrefixes);
	OFLog(@"C identifier prefix: %@", ns.cIdentifierPrefixes);

	for (GIRClass *girClass in ns.classes) {
		void *pool = objc_autoreleasePoolPush();

		if ([libraryInfo.excludeClasses containsObject:girClass.name])
			continue;

		OGTKClass *objCClass = [[[OGTKClass alloc] init] autorelease];

		[self mapGIRClass:girClass
		       toObjCClass:objCClass
		    usingNamespace:ns];

		@try {
			[mapper addClass:objCClass];
		} @catch (id e) {
			OFLog(@"Warning: Cannot add type %@ to mapper. "
			      @"Exception %@, description: %@"
			      @"Class definition may be incorrect. "
			      @"Skipping…",
			    objCClass.cName, [e class], [e description]);
			[mapper removeClass:objCClass];
		}
		objc_autoreleasePoolPop(pool);
	}
}

+ (void)writeClassFilesForLibrary:(OGTKLibrary *)libraryInfo
                            toDir:(OFString *)outputDir
    getClassDefinitionsFromMapper:(OGTKMapper *)mapper
{
	OFMutableDictionary *classesDict = mapper.objcTypeToClassMapping;

	OFString *libraryOutputDir =
	    [[outputDir stringByAppendingPathComponent:libraryInfo.name]
	        stringByAppendingPathComponent:@"src"];

	// Write the classes
	for (OFString *className in classesDict) {
		OGTKClass *classInfo = [classesDict objectForKey:className];
		if ([libraryInfo.namespace isEqual:classInfo.namespace]) {
			[OGTKClassWriter generateFilesForClass:classInfo
			                                 inDir:libraryOutputDir
			                            forLibrary:libraryInfo];
		}
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
	[objCClass setNamespace:ns.name];
	[objCClass setCNSIdentifierPrefix:[self firstOfKommaSeparatedElements:
	                                            ns.cIdentifierPrefixes]];
	[objCClass setCNSSymbolPrefix:
	               [self firstOfKommaSeparatedElements:ns.cSymbolPrefixes]];

	// Set constructors
	[self addMappedGIRMethods:girClass.constructors
	              toObjCClass:objCClass
	            usingSelector:@selector(addConstructor:)];

	// Set functions
	[self addMappedGIRMethods:girClass.functions
	              toObjCClass:objCClass
	            usingSelector:@selector(addFunction:)];

	// Set methods
	[self addMappedGIRMethods:girClass.methods
	              toObjCClass:objCClass
	            usingSelector:@selector(addMethod:)];
}

+ (void)addMappedGIRMethods:(OFMutableArray OF_GENERIC(
                                id<GIRMethodMapping>) *)girMethodArray
                toObjCClass:(OGTKClass *)objCClass
              usingSelector:(SEL)addMethodSelector
{
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

		OFString *methodName;
		if ([girMethod.name isEqual:@"errno"])
			methodName = @"errNo";
		else
			methodName = girMethod.name;

		[objcMethod setName:methodName];
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

			OFString *cType;
			if (param.type == nil && param.array != nil) {
				cType = param.array.cType;
			} else {
				cType = param.type.cType;
			}
			if ([cType containsString:@"const _"]) {
				cType = [cType
				    stringByReplacingOccurrencesOfString:@"const _"
				                              withString:
				                                  @"const "
				                                  @"struct _"];
			}
			[objcParam setCType:cType];

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
