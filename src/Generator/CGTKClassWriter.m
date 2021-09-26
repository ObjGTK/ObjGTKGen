/*
 * CGTKClassWriter.m
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
#import "CGTKClassWriter.h"

@implementation CGTKClassWriter

+ (void)generateFilesForClass:(CGTKClass*)cgtkClass inDir:(OFString*)outputDir
{
    OFFileManager* fileManager = [OFFileManager defaultManager];
    if (![fileManager directoryExistsAtPath:outputDir]) {
        [fileManager createDirectoryAtPath:outputDir createParents:true];
    }

    // Header
    OFString* hFilename = [[outputDir stringByAppendingPathComponent:[cgtkClass name]] stringByAppendingString:@".h"];
    [[CGTKClassWriter headerStringFor:cgtkClass] writeToFile:hFilename];

    // Source
    OFString* sFilename = [[outputDir stringByAppendingPathComponent:[cgtkClass name]] stringByAppendingString:@".m"];
    [[CGTKClassWriter sourceStringFor:cgtkClass] writeToFile:sFilename];
}

+ (OFString*)headerStringFor:(CGTKClass*)cgtkClass
{
    OFMutableString* output = [[OFMutableString alloc] init];

    [output appendString:[CGTKClassWriter generateLicense:[OFString stringWithFormat:@"%@.h", [cgtkClass name]]]];

    // Imports
    [output appendString:@"\n/*\n * Objective-C imports\n */\n"];
    [output appendFormat:@"#import \"CoreGTK/%@.h\"\n", [CGTKUtil swapTypes:[cgtkClass cParentType]]];

    OFArray* extraImports = [CGTKUtil extraImports:[cgtkClass type]];

    if (extraImports != nil) {
        for (OFString* imp in extraImports) {
            OFLog(@"%s", imp);
            [output appendFormat:@"#import %@\n", imp];
        }
    }

    [output appendString:@"\n"];

    // Interface declaration
    [output appendFormat:@"@interface %@ : %@\n{\n\n}\n\n", [cgtkClass name], [CGTKUtil swapTypes:[cgtkClass cParentType]]];

    // Function declarations
    if ([cgtkClass hasFunctions]) {
        [output appendString:@"/**\n * Functions\n */\n"];

        for (CGTKMethod* func in [cgtkClass functions]) {
            [output appendFormat:@"+(%@)%@;\n", [func returnType], [func sig]];
        }
    }

    if ([cgtkClass hasConstructors]) {
        [output appendString:@"\n/**\n * Constructors\n */\n"];

        // Constructor declarations
        for (CGTKMethod* ctor in [cgtkClass constructors]) {
            [output appendFormat:@"-(id)%@;\n", [CGTKUtil convertFunctionToInit:[ctor sig]]];
        }
    }

    [output appendString:@"\n/**\n * Methods\n */\n\n"];

    // Self type method declaration
    [output appendFormat:@"-(%@*)%@;\n", [cgtkClass cType], [[cgtkClass cName] uppercaseString]];

    OFDictionary* extraMethods = [CGTKUtil extraMethods:[cgtkClass type]];

    if (extraMethods != nil) {
        for (OFString* m in extraMethods) {
            [output appendFormat:@"\n%@;\n", m];
        }
    }

    for (CGTKMethod* meth in [cgtkClass methods]) {
        [output appendFormat:@"\n%@\n", [CGTKClassWriter generateDocumentationForMethod:meth]];
        [output appendFormat:@"-(%@)%@;\n", [meth returnType], [meth sig]];
    }

    // End interface
    [output appendString:@"\n@end"];

    return [output autorelease];
}

+ (OFString*)sourceStringFor:(CGTKClass*)cgtkClass
{
    OFMutableString* output = [[OFMutableString alloc] init];

    [output appendString:[CGTKClassWriter generateLicense:[OFString stringWithFormat:@"%@.m", [cgtkClass name]]]];

    // Imports
    [output appendString:@"\n/*\n * Objective-C imports\n */\n"];
    [output appendFormat:@"#import \"CoreGTK/%@.h\"\n\n", [cgtkClass name]];

    // Implementation declaration
    [output appendFormat:@"@implementation %@\n\n", [cgtkClass name]];

    // Function implementations
    for (CGTKMethod* func in [cgtkClass functions]) {
        [output appendFormat:@"+(%@)%@", [func returnType], [func sig]];

        [output appendString:@"\n{\n"];

        if ([func returnsVoid]) {
            [output appendFormat:@"\t%@(%@);\n", [func cName], [CGTKClassWriter generateCParameterListString:[func parameters]]];
        } else {
            // Need to add "return ..."
            [output appendString:@"\treturn "];

            if ([CGTKUtil isTypeSwappable:[func cReturnType]]) {
                // Need to swap type on return
                [output appendString:[CGTKUtil convertType:[func cReturnType] withName:[OFString stringWithFormat:@"%@(%@)", [func cName], [CGTKClassWriter generateCParameterListString:[func parameters]]] toType:[func returnType]]];
            } else {
                [output appendFormat:@"%@(%@)", [func cName], [CGTKClassWriter generateCParameterListString:[func parameters]]];
            }

            [output appendString:@";\n"];
        }

        [output appendString:@"}\n\n"];
    }

    OFDictionary* extraMethods = [CGTKUtil extraMethods:[cgtkClass type]];

    if (extraMethods != nil) {
        for (OFString* m in extraMethods) {
            [output appendFormat:@"%@\n%@\n\n", m, [extraMethods objectForKey:m]];
        }
    }

    // Constructor implementations
    for (CGTKMethod* ctor in [cgtkClass constructors]) {
        [output appendFormat:@"-(id)%@", [CGTKUtil convertFunctionToInit:[ctor sig]]];

        [output appendString:@"\n{\n"];

        [output appendFormat:@"\tself = %@;\n\n", [CGTKUtil getFunctionCallForConstructorOfType:[cgtkClass cType] withConstructor:[OFString stringWithFormat:@"%@(%@)", [ctor cName], [CGTKClassWriter generateCParameterListString:[ctor parameters]]]]];

        [output appendString:@"\tif(self)\n\t{\n\t\t//Do nothing\n\t}\n\n\treturn self;\n"];

        [output appendString:@"}\n\n"];
    }

    // Self type method implementation
    [output appendFormat:@"-(%@*)%@\n{\n\treturn %@;\n}\n\n", [cgtkClass cType], [[cgtkClass cName] uppercaseString], [CGTKUtil selfTypeMethodCall:[cgtkClass cType]]];

    for (CGTKMethod* meth in [cgtkClass methods]) {
        [output appendFormat:@"-(%@)%@", [meth returnType], [meth sig]];

        [output appendString:@"\n{\n"];

        if ([meth returnsVoid]) {
            [output appendFormat:@"\t%@(%@);\n", [meth cName], [CGTKClassWriter generateCParameterListWithInstanceString:[cgtkClass type] andParams:[meth parameters]]];
        } else {
            // Need to add "return ..."
            [output appendString:@"\treturn "];

            if ([CGTKUtil isTypeSwappable:[meth cReturnType]]) {
                // Need to swap type on return
                [output appendString:[CGTKUtil convertType:[meth cReturnType] withName:[OFString stringWithFormat:@"%@(%@)", [meth cName], [CGTKClassWriter generateCParameterListWithInstanceString:[cgtkClass type] andParams:[meth parameters]]] toType:[meth returnType]]];
            } else {
                [output appendFormat:@"%@(%@)", [meth cName], [CGTKClassWriter generateCParameterListWithInstanceString:[cgtkClass type] andParams:[meth parameters]]];
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
        CGTKParameter* p;
        for (i = 0; i < [params count]; i++) {
            p = [params objectAtIndex:i];
            [paramsOutput appendString:[CGTKUtil convertType:[p type] withName:[p name] toType:[p cType]]];

            if (i < [params count] - 1) {
                [paramsOutput appendString:@", "];
            }
        }
    }

    return [paramsOutput autorelease];
}

+ (OFString*)generateCParameterListWithInstanceString:(OFString*)instanceType andParams:(OFArray*)params
{
    int i;
    OFMutableString* paramsOutput = [[OFMutableString alloc] init];

    [paramsOutput appendString:[CGTKUtil selfTypeMethodCall:instanceType]];

    if (params != nil && [params count] > 0) {
        [paramsOutput appendString:@", "];

        CGTKParameter* p;

        // Start at index 1
        for (i = 0; i < [params count]; i++) {
            p = [params objectAtIndex:i];
            [paramsOutput appendString:[CGTKUtil convertType:[p type] withName:[p name] toType:[p cType]]];

            if (i < [params count] - 1) {
                [paramsOutput appendString:@", "];
            }
        }
    }

    return [paramsOutput autorelease];
}

+ (OFString*)generateLicense:(OFString*)fileName
{
    OFString* licText = [OFString stringWithContentsOfFile:@"Config/license.txt"];

    return [licText stringByReplacingOccurrencesOfString:@"@@@FILENAME@@@" withString:fileName];
}

+ (OFString*)generateDocumentationForMethod:(CGTKMethod*)meth
{
    int i;
    CGTKParameter* p = nil;

    OFMutableString* doc = [[OFMutableString alloc] init];

    [doc appendFormat:@"/**\n * -(%@*)%@;\n *\n", [meth returnType], [meth sig]];

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
