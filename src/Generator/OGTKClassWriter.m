/*
 * OGTKClassWriter.m
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

/*
 * Objective-C imports
 */
#import "OGTKClassWriter.h"

@implementation OGTKClassWriter

+ (void)generateFilesForClass:(OGTKClass *)cgtkClass
                        inDir:(OFString *)outputDir
                   forLibrary:(OGTKLibrary *)library
{
	OFFileManager *fileManager = [OFFileManager defaultManager];
	if (![fileManager directoryExistsAtPath:outputDir]) {
		[fileManager createDirectoryAtPath:outputDir
		                     createParents:true];
	}

	@try {
		// Header
		OFString *hFilename =
		    [[outputDir stringByAppendingPathComponent:[cgtkClass type]]
		        stringByAppendingString:@".h"];
		[[OGTKClassWriter headerStringFor:cgtkClass library:library]
		    writeToFile:hFilename];

		// Source
		OFString *sFilename =
		    [[outputDir stringByAppendingPathComponent:[cgtkClass type]]
		        stringByAppendingString:@".m"];
		[[OGTKClassWriter sourceStringFor:cgtkClass]
		    writeToFile:sFilename];
	} @catch (id e) {
		OFLog(@"Warning: Cannot generate file for type %@. "
		      @"Exception %@, description: %@ "
		      @"Class definition may be incorrect. Skipping…",
		    cgtkClass.cName, [e class], [e description]);
	}
}

+ (OFString *)headerStringFor:(OGTKClass *)cgtkClass
                      library:(OGTKLibrary *)library
{
	OFMutableString *output = [[OFMutableString alloc] init];

	// OFLog(@"Writing header file for class %@.", [cgtkClass type]);
	[output
	    appendString:[OGTKClassWriter
	                     generateLicense:[OFString stringWithFormat:@"%@.h",
	                                               [cgtkClass type]]]];

	[output appendString:@"\n"];

	// Library dependencies in case we have a class that is at the top of
	// the class dependency graph
	if (cgtkClass.topMostGraphNode) {
		for (GIRInclude *cInclude in library.cIncludes) {
			[output appendFormat:@"#include <%@>\n", cInclude.name];
		}
		[output appendString:@"\n"];
	}

	// Imports/Dependencies
	for (OFString *dependency in cgtkClass.dependsOnClasses) {

		if ([[OGTKMapper swapTypes:dependency] isEqual:@"OGObject"])
			[output appendString:@"#import \"OGObject.h\"\n"];
		else if ([OGTKMapper isGobjType:dependency] &&
		    [OGTKMapper isTypeSwappable:dependency]) {

			[output
			    appendString:[self importForDependency:dependency
			                                   ofClass:cgtkClass]];
		}
	}

	[output appendString:@"\n"];

	// Forward class declarations (for circular dependencies)
	if (cgtkClass.forwardDeclarationForClasses.count > 0) {
		for (OFString *gobjClassName in cgtkClass
		         .forwardDeclarationForClasses) {
			if ([OGTKMapper isGobjType:gobjClassName] &&
			    [OGTKMapper isTypeSwappable:gobjClassName])
				[output appendFormat:@"@class %@;\n",
				        [OGTKMapper swapTypes:gobjClassName]];
		}

		[output appendString:@"\n"];
	}

	// Class documentation
	if (cgtkClass.documentation != nil) {
		OFString *docText = [OGTKClassWriter
		    preparedDocumentationStringCopy:cgtkClass.documentation];

		[output appendFormat:@"/**\n * %@\n *\n */\n", docText];

		[docText release];
	}

	// Interface declaration
	[output appendFormat:@"@interface %@ : %@\n{\n\n}\n\n",
	        [cgtkClass type],
	        [OGTKMapper swapTypes:[cgtkClass cParentType]]];

	// Function declarations
	if ([cgtkClass hasFunctions]) {
		[output appendString:@"/**\n * Functions\n */\n"];

		for (OGTKMethod *func in [cgtkClass functions]) {
			[output appendFormat:@"+ (%@)%@;\n", [func returnType],
			        [func sig]];
		}
	}

	if ([cgtkClass hasConstructors]) {
		[output appendString:@"\n/**\n * Constructors\n */\n"];

		// Constructor declarations
		for (OGTKMethod *ctor in [cgtkClass constructors]) {
			[output appendFormat:@"- (instancetype)%@;\n",
			        [OGTKUtil convertFunctionToInit:[ctor sig]]];
		}
	}

	[output appendString:@"\n/**\n * Methods\n */\n\n"];

	// Self type method declaration
	[output appendFormat:@"- (%@*)%@;\n", [cgtkClass cType],
	        [[cgtkClass cName] uppercaseString]];

	for (OGTKMethod *meth in [cgtkClass methods]) {
		[output appendFormat:@"\n%@\n",
		        [OGTKClassWriter generateDocumentationForMethod:meth]];
		[output
		    appendFormat:@"- (%@)%@;\n", [meth returnType], [meth sig]];
	}

	// End interface
	[output appendString:@"\n@end"];

	return [output autorelease];
}

+ (OFString *)sourceStringFor:(OGTKClass *)cgtkClass
{
	OFMutableString *output = [[OFMutableString alloc] init];

	// OFLog(@"Writing implementation file for class %@.", [cgtkClass
	// type]);
	OFString *fileName =
	    [OFString stringWithFormat:@"%@.m", [cgtkClass type]];
	OFString *license = [OGTKClassWriter generateLicense:fileName];
	[output appendString:license];

	// Imports
	[output appendFormat:@"\n#import \"%@.h\"\n\n", [cgtkClass type]];

	// Imports for forward class declarations (for circular dependencies)
	if (cgtkClass.forwardDeclarationForClasses.count > 0) {
		for (OFString *gobjClassName in cgtkClass
		         .forwardDeclarationForClasses) {
			if ([OGTKMapper isGobjType:gobjClassName] &&
			    [OGTKMapper isTypeSwappable:gobjClassName]) {

				[output
				    appendString:
				        [self importForDependency:gobjClassName
				                          ofClass:cgtkClass]];
			}
		}

		[output appendString:@"\n"];
	}

	// Implementation declaration
	[output appendFormat:@"@implementation %@\n\n", [cgtkClass type]];

	// Function implementations
	for (OGTKMethod *func in [cgtkClass functions]) {
		[output
		    appendFormat:@"+ (%@)%@", [func returnType], [func sig]];

		[output appendString:@"\n{\n"];

		if ([func returnsVoid]) {
			[output
			    appendFormat:@"\t%@(%@);\n", [func cIdentifier],
			    [OGTKClassWriter
			        generateCParameterListString:[func
			                                         parameters]]];
		} else {
			// Need to add "return ..."
			[output appendString:@"\treturn "];

			if ([OGTKMapper isTypeSwappable:[func cReturnType]]) {
				// Need to swap type on return
				[output
				    appendString:
				        [OGTKMapper
				            convertType:[func cReturnType]
				               withName:
				                   [OFString
				                       stringWithFormat:
				                           @"%@(%@)",
				                       [func cIdentifier],
				                       [OGTKClassWriter
				                           generateCParameterListString:
				                               [func
				                                   parameters]]]
				                 toType:[func returnType]]];
			} else {
				[output appendFormat:@"%@(%@)",
				        [func cIdentifier],
				        [OGTKClassWriter
				            generateCParameterListString:
				                [func parameters]]];
			}

			[output appendString:@";\n"];
		}

		[output appendString:@"}\n\n"];
	}

	// Constructor implementations
	for (OGTKMethod *ctor in [cgtkClass constructors]) {
		[output appendFormat:@"- (instancetype)%@",
		        [OGTKUtil convertFunctionToInit:[ctor sig]]];

		[output appendString:@"\n{\n"];

		[output
		    appendFormat:@"\tself = %@;\n\n",
		    [OGTKUtil
		        getFunctionCallForConstructorOfType:[cgtkClass cType]
		                            withConstructor:
		                                [OFString
		                                    stringWithFormat:@"%@(%@)",
		                                    [ctor cIdentifier],
		                                    [OGTKClassWriter
		                                        generateCParameterListString:
		                                            [ctor
		                                                parameters]]]]];

		[output appendString:@"\treturn self;\n"];

		[output appendString:@"}\n\n"];
	}

	// Self type method implementation
	[output appendFormat:@"- (%@*)%@\n{\n\treturn %@;\n}\n\n",
	        [cgtkClass cType], [[cgtkClass cName] uppercaseString],
	        [OGTKMapper selfTypeMethodCall:[cgtkClass cType]]];

	for (OGTKMethod *meth in [cgtkClass methods]) {
		[output
		    appendFormat:@"- (%@)%@", [meth returnType], [meth sig]];

		[output appendString:@"\n{\n"];

		if ([meth returnsVoid]) {
			[output
			    appendFormat:@"\t%@(%@);\n", [meth cIdentifier],
			    [OGTKClassWriter
			        generateCParameterListWithInstanceString:
			            [cgtkClass type]
			                                       andParams:
			                                           [meth
			                                               parameters]]];
		} else {
			// Need to add "return ..."
			[output appendString:@"\treturn "];

			if ([OGTKMapper isTypeSwappable:[meth cReturnType]]) {
				// Need to swap type on return
				[output
				    appendString:
				        [OGTKMapper
				            convertType:[meth cReturnType]
				               withName:
				                   [OFString
				                       stringWithFormat:
				                           @"%@(%@)",
				                       [meth cIdentifier],
				                       [OGTKClassWriter
				                           generateCParameterListWithInstanceString:
				                               [cgtkClass type]
				                                                          andParams:
				                                                              [meth
				                                                                  parameters]]]
				                 toType:[meth returnType]]];
			} else {
				[output
				    appendFormat:@"%@(%@)", [meth cIdentifier],
				    [OGTKClassWriter
				        generateCParameterListWithInstanceString:
				            [cgtkClass type]
				                                       andParams:
				                                           [meth
				                                               parameters]]];
			}

			[output appendString:@";\n"];
		}

		[output appendString:@"}\n\n"];
	}

	// End implementation
	[output appendString:@"\n@end"];

	return [output autorelease];
}

+ (OFString *)importForDependency:(OFString *)dependency
                          ofClass:(OGTKClass *)classInfo
{
	OGTKClass *dependencyClassInfo =
	    [OGTKMapper classInfoByGobjType:dependency];

	OFString *result;

	// If parent lib is from this library
	if ([classInfo.namespace isEqual:dependencyClassInfo.namespace]) {

		result = [OFString stringWithFormat:@"#import \"%@.h\"\n",
		                   [OGTKMapper swapTypes:dependency]];

	} else {
		// We need to get the ObjC name of the
		// external library in order to provide
		// the correct header directive
		OGTKLibrary *libraryInfo = [OGTKMapper
		    libraryInfoByNamespace:dependencyClassInfo.namespace];

		result = [OFString stringWithFormat:@"#import <%@/%@.h>\n",
		                   libraryInfo.name,
		                   [OGTKMapper swapTypes:dependency]];
	}

	return result;
}

+ (void)generateUmbrellaHeaderFileForClasses:
            (OFDictionary OF_GENERIC(OFString *, OGTKClass *) *)objCClassesDict
                                       inDir:(OFString *)outputDir
                                  forLibrary:(OGTKLibrary *)libraryInfo
                readAdditionalHeadersFromDir:(OFString *)additionalHeaderDir
{
	OFString *libName = libraryInfo.name;
	OFMutableString *output = [OFMutableString string];

	OFString *fileName =
	    [OFString stringWithFormat:@"%@-Umbrella.h", libName];
	OFString *license = [OGTKClassWriter generateLicense:fileName];
	[output appendString:license];

	[output appendString:@"\n#import <ObjFW/ObjFW.h>\n\n"];

	if (additionalHeaderDir != nil) {
		[output appendString:@"// Manually written classes\n"];

		[OGTKClassWriter
		    addImportsForHeaderFilesInDir:
		        [additionalHeaderDir
		            stringByAppendingPathComponent:@"General"]
		                         toString:output];

		@try {
			[OGTKClassWriter
			    addImportsForHeaderFilesInDir:
			        [additionalHeaderDir
			            stringByAppendingPathComponent:libName]
			                         toString:output];
		} @catch (OFReadFailedException *e) {
			OFLog(@"No additional base classes dir for "
			      @"library %@, "
			      @"importing only general and generated "
			      @"header "
			      @"files.",
			    libName);
		}

		[output appendString:@"\n"];
	}

	[output appendString:@"// Generated classes\n"];

	for (OFString *objCClassName in objCClassesDict) {
		OGTKClass *classInfo =
		    [objCClassesDict objectForKey:objCClassName];
		if ([libraryInfo.namespace isEqual:classInfo.namespace])
			[output
			    appendFormat:@"#import \"%@.h\"\n", objCClassName];
	}

	OFString *hFilePath =
	    [outputDir stringByAppendingPathComponent:fileName];

	[output writeToFile:hFilePath];
}

+ (void)addImportsForHeaderFilesInDir:(OFString *)dirPath
                             toString:(OFMutableString *)string
{
	OFFileManager *fileMgr = [OFFileManager defaultManager];

	if (![fileMgr directoryExistsAtPath:dirPath]) {
		@throw [OFReadFailedException exceptionWithObject:dirPath
		                                  requestedLength:0
		                                            errNo:0];
	}

	OFArray *srcDirContents = [fileMgr contentsOfDirectoryAtPath:dirPath];

	for (OFString *srcFile in srcDirContents) {
		OFString *additionalFile = [srcFile lastPathComponent];
		if ([additionalFile containsString:@".h"]) {
			[string
			    appendFormat:@"#import \"%@\"\n", additionalFile];
		}
	}
}

+ (OFString *)generateCParameterListString:(OFArray *)params
{
	OFMutableString *paramsOutput = [OFMutableString string];

	size_t i = 0, count = params.count;
	for (OGTKParameter *param in params) {
		[paramsOutput
		    appendString:[OGTKMapper convertType:param.type
		                                withName:param.name
		                                  toType:param.cType]];

		if (i++ < count - 1)
			[paramsOutput appendString:@", "];
	}

	return paramsOutput;
}

+ (OFString *)generateCParameterListWithInstanceString:(OFString *)instanceType
                                             andParams:(OFArray *)params
{
	OFMutableString *paramsOutput = [OFMutableString string];

	[paramsOutput
	    appendString:[OGTKMapper selfTypeMethodCall:instanceType]];

	if (params != nil && [params count] > 0) {
		[paramsOutput appendString:@", "];

		OGTKParameter *p;

		// Start at index 1
		size_t i;
		for (i = 0; i < [params count]; i++) {
			p = [params objectAtIndex:i];
			[paramsOutput
			    appendString:[OGTKMapper convertType:[p type]
			                                withName:[p name]
			                                  toType:[p cType]]];

			if (i < [params count] - 1) {
				[paramsOutput appendString:@", "];
			}
		}
	}

	return [paramsOutput autorelease];
}

+ (OFString *)generateLicense:(OFString *)fileName
{
	OFString *licText =
	    [OFString stringWithContentsOfFile:@"Config/license.txt"];

	return [licText stringByReplacingOccurrencesOfString:@"@@@FILENAME@@@"
	                                          withString:fileName];
}

+ (OFString *)preparedDocumentationStringCopy:(OFString *)unpreparedText
{
	OFMutableString *docText =
	    [[unpreparedText stringByDeletingEnclosingWhitespaces] mutableCopy];
	[docText replaceOccurrencesOfString:@"\n" withString:@"\n * "];

	[docText makeImmutable];

	return docText;
}

+ (OFString *)generateDocumentationForMethod:(OGTKMethod *)meth
{
	OFMutableString *doc = [[OFMutableString alloc] init];

	OFString *docText;

	if (meth.documentation != nil) {
		docText = [OGTKClassWriter
		    preparedDocumentationStringCopy:meth.documentation];

		[doc appendFormat:@"/**\n * %@\n *\n", docText];
		[docText release];
	} else {
		[doc appendString:@"/**\n *\n"];
	}

	if ([meth.parameters count] > 0) {
		for (OGTKParameter *parameter in meth.parameters) {

			if (parameter.documentation != nil) {
				docText = [OGTKClassWriter
				    preparedDocumentationStringCopy:
				        parameter.documentation];

				[doc appendFormat:@" * @param %@ %@\n",
				     parameter.name, docText];

				[docText release];
			} else {
				[doc appendFormat:@" * @param %@\n",
				     parameter.name];
			}
		}
	}

	if (![meth returnsVoid]) {
		if (meth.returnValueDocumentation != nil) {
			docText =
			    [OGTKClassWriter preparedDocumentationStringCopy:
			                         meth.returnValueDocumentation];

			[doc appendFormat:@" * @return %@\n", docText];

			[docText release];
		} else {
			[doc appendString:@" * @return\n"];
		}
	}

	[doc appendString:@" */"];

	return [doc autorelease];
}

@end
