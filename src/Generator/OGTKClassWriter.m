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
#include <ObjFW/OFStdIOStream.h>

@implementation OGTKClassWriter

+ (void)generateFilesForClass:(OGTKClass*)cgtkClass inDir:(OFString*)outputDir
{
    OFFileManager* fileManager = [OFFileManager defaultManager];
    if (![fileManager directoryExistsAtPath:outputDir]) {
        [fileManager createDirectoryAtPath:outputDir createParents:true];
    }

    @try {
        // Header
        OFString* hFilename =
            [[outputDir stringByAppendingPathComponent:[cgtkClass name]]
                stringByAppendingString:@".h"];
        [[OGTKClassWriter headerStringFor:cgtkClass] writeToFile:hFilename];

        // Source
        OFString* sFilename =
            [[outputDir stringByAppendingPathComponent:[cgtkClass name]]
                stringByAppendingString:@".m"];
        [[OGTKClassWriter sourceStringFor:cgtkClass] writeToFile:sFilename];
    } @catch (id e) {
        OFLog(@"Warning: Cannot generate file for definition for class %@. "
              @"Definition may be incorrect. Skipping…",
            cgtkClass.name);
    }
}

+ (OFString*)headerStringFor:(OGTKClass*)cgtkClass
{
    OFMutableString* output = [[OFMutableString alloc] init];

    // OFLog(@"Writing header file for class %@.", [cgtkClass name]);
    [output appendString:[OGTKClassWriter
                             generateLicense:[OFString stringWithFormat:@"%@.h",
                                                       [cgtkClass name]]]];

    // Imports
    [output appendString:@"\n/*\n * Objective-C imports\n */\n"];
    [output appendFormat:@"#import \"%@.h\"\n",
            [OGTKUtil swapTypes:[cgtkClass cParentType]]];

    OFArray* extraImports = [OGTKUtil extraImports:[cgtkClass type]];

    if (extraImports != nil) {
        for (OFString* imp in extraImports) {
            if (imp != nil) {
                [output appendFormat:@"#import %@\n", imp];
            }
        }
    }

    [output appendString:@"\n"];

    // Interface declaration
    [output appendFormat:@"@interface %@ : %@\n{\n\n}\n\n", [cgtkClass name],
            [OGTKUtil swapTypes:[cgtkClass cParentType]]];

    // Function declarations
    if ([cgtkClass hasFunctions]) {
        [output appendString:@"/**\n * Functions\n */\n"];

        for (OGTKMethod* func in [cgtkClass functions]) {
            [output appendFormat:@"+ (%@)%@;\n", [func returnType], [func sig]];
        }
    }

    if ([cgtkClass hasConstructors]) {
        [output appendString:@"\n/**\n * Constructors\n */\n"];

        // Constructor declarations
        for (OGTKMethod* ctor in [cgtkClass constructors]) {
            [output appendFormat:@"- (id)%@;\n",
                    [OGTKUtil convertFunctionToInit:[ctor sig]]];
        }
    }

    [output appendString:@"\n/**\n * Methods\n */\n\n"];

    // Self type method declaration
    [output appendFormat:@"- (%@*)%@;\n", [cgtkClass cType],
            [[cgtkClass cName] uppercaseString]];

    OFDictionary* extraMethods = [OGTKUtil extraMethods:[cgtkClass type]];

    if (extraMethods != nil) {
        for (OFString* m in extraMethods) {
            [output appendFormat:@"\n%@;\n", m];
        }
    }

    for (OGTKMethod* meth in [cgtkClass methods]) {
        [output appendFormat:@"\n%@\n",
                [OGTKClassWriter generateDocumentationForMethod:meth]];
        [output appendFormat:@"- (%@)%@;\n", [meth returnType], [meth sig]];
    }

    // End interface
    [output appendString:@"\n@end"];

    return [output autorelease];
}

+ (OFString*)sourceStringFor:(OGTKClass*)cgtkClass
{
    OFMutableString* output = [[OFMutableString alloc] init];

    // OFLog(@"Writing implementation file for class %@.", [cgtkClass name]);
    [output appendString:[OGTKClassWriter
                             generateLicense:[OFString stringWithFormat:@"%@.m",
                                                       [cgtkClass name]]]];

    // Imports
    [output appendString:@"\n/*\n * Objective-C imports\n */\n"];
    [output appendFormat:@"#import \"%@.h\"\n\n", [cgtkClass name]];

    // Implementation declaration
    [output appendFormat:@"@implementation %@\n\n", [cgtkClass name]];

    // Function implementations
    for (OGTKMethod* func in [cgtkClass functions]) {
        [output appendFormat:@"+ (%@)%@", [func returnType], [func sig]];

        [output appendString:@"\n{\n"];

        if ([func returnsVoid]) {
            [output appendFormat:@"\t%@(%@);\n", [func cName],
                    [OGTKClassWriter
                        generateCParameterListString:[func parameters]]];
        } else {
            // Need to add "return ..."
            [output appendString:@"\treturn "];

            if ([OGTKUtil isTypeSwappable:[func cReturnType]]) {
                // Need to swap type on return
                [output
                    appendString:
                        [OGTKUtil
                            convertType:[func cReturnType]
                               withName:[OFString
                                            stringWithFormat:@"%@(%@)",
                                            [func cName],
                                            [OGTKClassWriter
                                                generateCParameterListString:
                                                    [func parameters]]]
                                 toType:[func returnType]]];
            } else {
                [output appendFormat:@"%@(%@)", [func cName],
                        [OGTKClassWriter
                            generateCParameterListString:[func parameters]]];
            }

            [output appendString:@";\n"];
        }

        [output appendString:@"}\n\n"];
    }

    OFDictionary* extraMethods = [OGTKUtil extraMethods:[cgtkClass type]];

    if (extraMethods != nil) {
        for (OFString* m in extraMethods) {
            [output
                appendFormat:@"%@\n%@\n\n", m, [extraMethods objectForKey:m]];
        }
    }

    // Constructor implementations
    for (OGTKMethod* ctor in [cgtkClass constructors]) {
        [output appendFormat:@"- (id)%@",
                [OGTKUtil convertFunctionToInit:[ctor sig]]];

        [output appendString:@"\n{\n"];

        [output
            appendFormat:@"\tself = %@;\n\n",
            [OGTKUtil
                getFunctionCallForConstructorOfType:[cgtkClass cType]
                                    withConstructor:
                                        [OFString
                                            stringWithFormat:@"%@(%@)",
                                            [ctor cName],
                                            [OGTKClassWriter
                                                generateCParameterListString:
                                                    [ctor parameters]]]]];

        [output appendString:@"\treturn self;\n"];

        [output appendString:@"}\n\n"];
    }

    // Self type method implementation
    [output appendFormat:@"- (%@*)%@\n{\n\treturn %@;\n}\n\n",
            [cgtkClass cType], [[cgtkClass cName] uppercaseString],
            [OGTKUtil selfTypeMethodCall:[cgtkClass cType]]];

    for (OGTKMethod* meth in [cgtkClass methods]) {
        [output appendFormat:@"- (%@)%@", [meth returnType], [meth sig]];

        [output appendString:@"\n{\n"];

        if ([meth returnsVoid]) {
            [output
                appendFormat:@"\t%@(%@);\n", [meth cName],
                [OGTKClassWriter
                    generateCParameterListWithInstanceString:[cgtkClass type]
                                                   andParams:[meth
                                                                 parameters]]];
        } else {
            // Need to add "return ..."
            [output appendString:@"\treturn "];

            if ([OGTKUtil isTypeSwappable:[meth cReturnType]]) {
                // Need to swap type on return
                [output
                    appendString:
                        [OGTKUtil
                            convertType:[meth cReturnType]
                               withName:
                                   [OFString
                                       stringWithFormat:@"%@(%@)", [meth cName],
                                       [OGTKClassWriter
                                           generateCParameterListWithInstanceString:
                                               [cgtkClass type]
                                                                          andParams:
                                                                              [meth
                                                                                  parameters]]]
                                 toType:[meth returnType]]];
            } else {
                [output
                    appendFormat:@"%@(%@)", [meth cName],
                    [OGTKClassWriter
                        generateCParameterListWithInstanceString:[cgtkClass
                                                                     type]
                                                       andParams:
                                                           [meth parameters]]];
            }

            [output appendString:@";\n"];
        }

        [output appendString:@"}\n\n"];
    }

    // End implementation
    [output appendString:@"\n@end"];

    return [output autorelease];
}

+ (OFString*)generateCParameterListString:(OFArray*)params
{
    int i;
    OFMutableString* paramsOutput = [[OFMutableString alloc] init];

    if (params != nil && [params count] > 0) {
        OGTKParameter* p;
        for (i = 0; i < [params count]; i++) {
            p = [params objectAtIndex:i];
            [paramsOutput appendString:[OGTKUtil convertType:[p type]
                                                    withName:[p name]
                                                      toType:[p cType]]];

            if (i < [params count] - 1) {
                [paramsOutput appendString:@", "];
            }
        }
    }

    return [paramsOutput autorelease];
}

+ (OFString*)generateCParameterListWithInstanceString:(OFString*)instanceType
                                            andParams:(OFArray*)params
{
    int i;
    OFMutableString* paramsOutput = [[OFMutableString alloc] init];

    [paramsOutput appendString:[OGTKUtil selfTypeMethodCall:instanceType]];

    if (params != nil && [params count] > 0) {
        [paramsOutput appendString:@", "];

        OGTKParameter* p;

        // Start at index 1
        for (i = 0; i < [params count]; i++) {
            p = [params objectAtIndex:i];
            [paramsOutput appendString:[OGTKUtil convertType:[p type]
                                                    withName:[p name]
                                                      toType:[p cType]]];

            if (i < [params count] - 1) {
                [paramsOutput appendString:@", "];
            }
        }
    }

    return [paramsOutput autorelease];
}

+ (OFString*)generateLicense:(OFString*)fileName
{
    OFString* licText =
        [OFString stringWithContentsOfFile:@"Config/license.txt"];

    return [licText stringByReplacingOccurrencesOfString:@"@@@FILENAME@@@"
                                              withString:fileName];
}

+ (OFString*)generateDocumentationForMethod:(OGTKMethod*)meth
{
    int i;
    OGTKParameter* p = nil;

    OFMutableString* doc = [[OFMutableString alloc] init];

    [doc appendFormat:@"/**\n * - (%@*)%@;\n *\n", [meth returnType],
         [meth sig]];

    if ([meth.parameters count] > 0) {
        for (i = 0; i < [meth.parameters count]; i++) {
            p = [meth.parameters objectAtIndex:i];

            [doc appendFormat:@" * @param %@\n", [p name]];
        }
    }

    if (![meth returnsVoid]) {
        [doc appendFormat:@" * @returns %@\n", [meth returnType]];
    }

    [doc appendString:@" */"];

    return [doc autorelease];
}

@end