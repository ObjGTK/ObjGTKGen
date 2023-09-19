/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2023 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2023 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "OGTKClassWriter.h"

@interface OGTKClassWriter ()
- (OFString *)importForDependency:(OFString *)dependencyGobjType;
- (OFString *)preparedDocumentationStringCopy:(OFString *)unpreparedText;
@end

@implementation OGTKClassWriter

@synthesize classDescription = _classDescription,
            libraryDescription = _libraryDescription;

static OFString *const CErrorParameterName = @"&err";
static OFString *const PrepareErrorHandling = @"\tGError* err = NULL;\n\n";
static OFString *const ErrorHandling =
    @"\tif(err != NULL) {\n"
    @"\t\tOGErrorException* exception = [OGErrorException "
    @"exceptionWithGError:err];\n"
    @"\t\tg_error_free(err);\n"
    @"\t\t@throw exception;\n"
    @"\t}\n\n";
static OFString *const InitErrorHandling =
    @"\t@try {"
    @"\t\tif(err != NULL) {\n"
    @"\t\t\tOGErrorException* exception = [OGErrorException "
    @"exceptionWithGError:err];\n"
    @"\t\t\tg_error_free(err);\n"
    @"\t\t\t@throw exception;\n"
    @"\t\t}\n"
    @"\t} @catch (id e) {"
    @"\t\t[self release];"
    @"\t\t@throw e;"
    @"\t}";

- (instancetype)init
{
	OF_INVALID_INIT_METHOD
}

- (instancetype)initWithClass:(OGTKClass *)classDescription
                      library:(OGTKLibrary *)libraryDescription
{
	self = [super init];

	@try {
		_classDescription = classDescription;
		[_classDescription retain];

		_libraryDescription = libraryDescription;
		[_libraryDescription retain];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[_classDescription release];
	[_libraryDescription release];

	[super dealloc];
}

- (void)generateFilesInDir:(OFString *)outputDir
{
	OFFileManager *fileManager = [OFFileManager defaultManager];
	if (![fileManager directoryExistsAtPath:outputDir]) {
		[fileManager createDirectoryAtPath:outputDir
		                     createParents:true];
	}

	@try {
		// Header
		OFString *hFilename = [[outputDir
		    stringByAppendingPathComponent:_classDescription.type]
		    stringByAppendingString:@".h"];

		[[self headerString] writeToFile:hFilename];

		// Source
		OFString *sFilename = [[outputDir
		    stringByAppendingPathComponent:_classDescription.type]
		    stringByAppendingString:@".m"];

		[[self sourceString] writeToFile:sFilename];
	} @catch (id e) {
		OFLog(@"Warning: Cannot generate file for type %@. "
		      @"Exception %@, description: %@ "
		      @"Class definition may be incorrect. Skipping…",
		    _classDescription.cName, [e class], [e description]);
	}
}

- (OFString *)headerString
{
	OFMutableString *output = [[OFMutableString alloc] init];

	// OFLog(@"Writing header file for class %@.", _classDescription.type);
	[output appendString:[OGTKClassWriter
	                         generateLicense:[OFString
	                                             stringWithFormat:@"%@.h",
	                                             _classDescription.type]]];

	[output appendString:@"\n"];

	// Imports/Dependencies
	OFMutableString *importDependencies = [OFMutableString string];
	for (OFString *dependency in _classDescription.dependsOnClasses) {

		if ([[OGTKMapper swapTypes:dependency] isEqual:@"OGObject"])
			[importDependencies
			    appendString:@"#import <OGObject/OGObject.h>\n"];
		else if ([OGTKMapper isGobjType:dependency] &&
		    [OGTKMapper isTypeSwappable:dependency]) {

			[importDependencies
			    appendString:[self importForDependency:dependency]];
		}
	}

	// Library dependencies in case we have a class that is at the top of
	// the class dependency graph
	OFMutableString *includes = [OFMutableString string];
	if (_classDescription.topMostGraphNode) {
		for (GIRInclude *cInclude in _libraryDescription.cIncludes) {
			[includes
			    appendFormat:@"#include <%@>\n", cInclude.name];
		}
		[includes appendString:@"\n"];
	}

	[output appendString:includes];
	[output appendString:importDependencies];
	[output appendString:@"\n"];

	// Forward class declarations (for circular dependencies)
	if (_classDescription.forwardDeclarationForClasses.count > 0) {
		for (OFString *gobjClassName in _classDescription
		         .forwardDeclarationForClasses) {
			if ([OGTKMapper isGobjType:gobjClassName] &&
			    [OGTKMapper isTypeSwappable:gobjClassName])
				[output appendFormat:@"@class %@;\n",
				        [OGTKMapper swapTypes:gobjClassName]];
		}

		[output appendString:@"\n"];
	}

	// Class documentation
	if (_classDescription.documentation != nil) {
		OFString *docText =
		    [self preparedDocumentationStringCopy:_classDescription
		                                              .documentation];

		[output appendFormat:@"/**\n * %@\n *\n */\n", docText];

		[docText release];
	}

	// Interface declaration
	[output appendFormat:@"@interface %@ : %@\n{\n\n}\n\n",
	        [_classDescription type],
	        [OGTKMapper swapTypes:[_classDescription cParentType]]];

	// Function declarations
	if (_classDescription.hasFunctions) {
		[output appendString:@"/**\n * Functions\n */\n"];

		for (OGTKMethod *func in _classDescription.functions) {
			[output appendFormat:@"\n%@\n",
			        [self generateDocumentationForMethod:func]];

			[output appendFormat:@"+ (%@)%@;\n", func.returnType,
			        func.sig];
		}
	}

	if (_classDescription.hasConstructors) {
		[output appendString:@"\n/**\n * Constructors\n */\n"];

		// Constructor declarations
		for (OGTKMethod *ctor in _classDescription.constructors) {
			[output appendFormat:@"- (instancetype)%@;\n",
			        [OGTKUtil convertFunctionToInit:ctor.sig]];
		}
	}

	[output appendString:@"\n/**\n * Methods\n */\n\n"];

	// GObject getter method declaration
	[output appendFormat:@"- (%@*)%@;\n", _classDescription.cType,
	        @"castedGObject"];

	for (OGTKMethod *meth in _classDescription.methods) {
		[output appendFormat:@"\n%@\n",
		        [self generateDocumentationForMethod:meth]];
		[output appendFormat:@"- (%@)%@;\n", meth.returnType, meth.sig];
	}

	// End interface
	[output appendString:@"\n@end"];

	return [output autorelease];
}

- (OFString *)sourceString
{
	OFMutableString *output = [OFMutableString string];

	// OFLog(@"Writing implementation file for class %@.",
	// _classDescription.type);
	OFString *fileName =
	    [OFString stringWithFormat:@"%@.m", _classDescription.type];
	OFString *license = [OGTKClassWriter generateLicense:fileName];
	[output appendString:license];

	// Imports
	[output appendFormat:@"\n#import \"%@.h\"\n\n", _classDescription.type];

	// Imports for forward class declarations (for circular dependencies)
	if (_classDescription.forwardDeclarationForClasses.count > 0) {
		for (OFString *gobjClassName in _classDescription
		         .forwardDeclarationForClasses) {
			if ([OGTKMapper isGobjType:gobjClassName] &&
			    [OGTKMapper isTypeSwappable:gobjClassName]) {

				[output appendString:[self importForDependency:
				                               gobjClassName]];
			}
		}

		[output appendString:@"\n"];
	}

	// Implementation declaration
	[output appendFormat:@"@implementation %@\n\n", _classDescription.type];

	// Class function implementation
	for (OGTKMethod *func in _classDescription.functions) {
		[output appendFormat:@"+ (%@)%@", func.returnType, func.sig];

		[output appendString:@"\n{\n"];

		if (func.throws)
			[output appendString:PrepareErrorHandling];

		if (func.returnsVoid) {
			[output
			    appendFormat:@"\t%@(%@);\n", func.cIdentifier,
			    [self generateCParameterListString:func.parameters
			                       throwsException:func.throws]];

			if (func.throws)
				[output appendString:ErrorHandling];

		} else {
			// Need to add "return ..."
			[output appendFormat:@"\t%@ returnValue = ",
			        func.returnType];

			if ([OGTKMapper isTypeSwappable:[func cReturnType]]) {
				// Need to swap type on return

				OFString *returnCall = [OFString
				    stringWithFormat:@"%@(%@)",
				    [func cIdentifier],
				    [self generateCParameterListString:
				              func.parameters
				                       throwsException:
				                           func.throws]];

				[output appendString:
				            [OGTKMapper
				                convertType:func.cReturnType
				                   withName:returnCall
				                     toType:func.returnType]];

			} else {
				[output appendFormat:@"%@(%@)",
				        func.cIdentifier,
				        [self generateCParameterListString:
				                  func.parameters
				                           throwsException:
				                               func.throws]];
			}

			[output appendString:@";\n\n"];

			if (func.throws)
				[output appendString:ErrorHandling];

			[output appendString:@"\treturn returnValue;\n"];
		}

		[output appendString:@"}\n\n"];
	}

	// Constructor implementations
	for (OGTKMethod *ctor in _classDescription.constructors) {
		[output appendFormat:@"- (instancetype)%@",
		        [OGTKUtil convertFunctionToInit:[ctor sig]]];

		[output appendString:@"\n{\n"];

		if (ctor.throws)
			[output appendString:PrepareErrorHandling];

		OFString *constructorCall =
		    [OFString stringWithFormat:@"%@(%@)", ctor.cIdentifier,
		              [self generateCParameterListString:ctor.parameters
		                                 throwsException:ctor.throws]];

		[output
		    appendFormat:@"\tself = %@;\n\n",
		    [OGTKUtil
		        getFunctionCallForConstructorOfType:_classDescription
		                                                .cType
		                            withConstructor:constructorCall]];

		if (ctor.throws)
			[output appendString:InitErrorHandling];

		[output appendString:@"\treturn self;\n"];

		[output appendString:@"}\n\n"];
	}

	// GObject getter method implementation
	[output appendFormat:@"- (%@*)%@\n{\n\treturn %@;\n}\n\n",
	        _classDescription.cType, @"castedGObject",
	        [OGTKMapper selfTypeMethodCall:_classDescription.cType]];

	// Method implementations
	for (OGTKMethod *meth in _classDescription.methods) {
		[output appendFormat:@"- (%@)%@", meth.returnType, meth.sig];

		[output appendString:@"\n{\n"];

		if (meth.throws)
			[output appendString:PrepareErrorHandling];

		if (meth.returnsVoid) {
			[output
			    appendFormat:@"\t%@(%@);\n", meth.cIdentifier,
			    [self
			        generateCParameterListWithInstanceString:
			            _classDescription.type
			                                       andParams:
			                                           meth.parameters
			                                 throwsException:
			                                     meth.throws]];

			if (meth.throws)
				[output appendString:ErrorHandling];

		} else {
			// Need to add "return ..."
			[output appendFormat:@"\t%@ returnValue = ",
			        meth.returnType];

			if ([OGTKMapper isTypeSwappable:meth.cReturnType]) {
				// Need to swap type on return

				OFString *returnCall = [OFString
				    stringWithFormat:@"%@(%@)",
				    meth.cIdentifier,
				    [self
				        generateCParameterListWithInstanceString:
				            _classDescription.type
				                                       andParams:
				                                           meth.parameters
				                                 throwsException:
				                                     meth.throws]];

				[output appendString:
				            [OGTKMapper
				                convertType:meth.cReturnType
				                   withName:returnCall
				                     toType:meth.returnType]];
			} else {
				[output
				    appendFormat:@"%@(%@)", meth.cIdentifier,
				    [self
				        generateCParameterListWithInstanceString:
				            _classDescription.type
				                                       andParams:
				                                           meth.parameters
				                                 throwsException:
				                                     meth.throws]];
			}

			[output appendString:@";\n\n"];

			if (meth.throws)
				[output appendString:ErrorHandling];

			[output appendString:@"\treturn returnValue;\n"];
		}

		[output appendString:@"}\n\n"];
	}

	// End implementation
	[output appendString:@"\n@end"];

	return output;
}

- (OFString *)importForDependency:(OFString *)dependencyGobjType
{
	OGTKClass *dependencyClassDescription =
	    [OGTKMapper classInfoByGobjType:dependencyGobjType];

	OFString *result;

	// If parent lib is from this library
	if ([_classDescription.namespace
	        isEqual:dependencyClassDescription.namespace]) {

		result = [OFString stringWithFormat:@"#import \"%@.h\"\n",
		                   [OGTKMapper swapTypes:dependencyGobjType]];

	} else {
		// We need to get the ObjC name of the
		// external library in order to provide
		// the correct header directive
		OGTKLibrary *depLibDescr = [OGTKMapper
		    libraryInfoByNamespace:dependencyClassDescription
		                               .namespace];

		if (depLibDescr == nil)
			@throw [OFUndefinedKeyException
			    exceptionWithObject:[OGTKMapper sharedMapper]
			                    key:dependencyClassDescription
			                            .namespace];

		// Make sure we include the libs own header, because the parent
		// class will introduce headers of its library. Otherwise we
		// may get undefined symbols for this class
		_classDescription.topMostGraphNode = true;

		result = [OFString stringWithFormat:@"#import <%@/%@.h>\n",
		                   depLibDescr.name,
		                   dependencyClassDescription.type];
	}

	return result;
}

- (OFString *)generateCParameterListString:(OFArray OF_GENERIC(
                                               OGTKParameter *) *)params
                           throwsException:(bool)throws
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

	if (throws && count > 0) {
		[paramsOutput appendFormat:@", %@", CErrorParameterName];
	} else if (throws && count == 0) {
		[paramsOutput appendString:CErrorParameterName];
	}

	return paramsOutput;
}

- (OFString *)generateCParameterListWithInstanceString:(OFString *)instanceType
                                             andParams:
                                                 (OFArray OF_GENERIC(
                                                     OGTKParameter *) *)params
                                       throwsException:(bool)throws
{
	OFMutableString *paramsOutput = [OFMutableString string];

	[paramsOutput
	    appendString:[OGTKMapper selfTypeMethodCall:instanceType]];

	size_t count = params.count;

	if (params != nil && count > 0) {
		[paramsOutput appendString:@", "];

		// Start at index 1
		size_t i = 0;
		for (OGTKParameter *param in params) {
			[paramsOutput
			    appendString:[OGTKMapper convertType:param.type
			                                withName:param.name
			                                  toType:param.cType]];

			if (i++ < count - 1) {
				[paramsOutput appendString:@", "];
			}
		}
	}

	if (throws)
		[paramsOutput appendFormat:@", %@", CErrorParameterName];

	return paramsOutput;
}

+ (OFString *)generateLicense:(OFString *)fileName
{
	OFString *licText = [OFString
	    stringWithContentsOfFile:
	        [[OGTKUtil dataDir]
	            stringByAppendingPathComponent:@"Config/license.txt"]];

	return [licText stringByReplacingOccurrencesOfString:@"@@@FILENAME@@@"
	                                          withString:fileName];
}

- (OFString *)preparedDocumentationStringCopy:(OFString *)unpreparedText
{
	OFMutableString *docText =
	    [[unpreparedText stringByDeletingEnclosingWhitespaces] mutableCopy];
	[docText replaceOccurrencesOfString:@"\n" withString:@"\n * "];

	[docText makeImmutable];

	return docText;
}

- (OFString *)generateDocumentationForMethod:(OGTKMethod *)meth
{
	OFMutableString *doc = [OFMutableString string];

	OFString *docText;

	if (meth.documentation != nil) {
		docText =
		    [self preparedDocumentationStringCopy:meth.documentation];

		[doc appendFormat:@"/**\n * %@\n *\n", docText];
		[docText release];
	} else {
		[doc appendString:@"/**\n *\n"];
	}

	if ([meth.parameters count] > 0) {
		for (OGTKParameter *parameter in meth.parameters) {

			if (parameter.documentation != nil) {
				docText = [self preparedDocumentationStringCopy:
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
			docText = [self preparedDocumentationStringCopy:
			                    meth.returnValueDocumentation];

			[doc appendFormat:@" * @return %@\n", docText];

			[docText release];
		} else {
			[doc appendString:@" * @return\n"];
		}
	}

	[doc appendString:@" */"];

	return doc;
}

@end
