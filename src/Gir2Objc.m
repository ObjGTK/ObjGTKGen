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
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 */

#import "Gir2Objc.h"

@implementation Gir2Objc

+ (void)parseGirFromFile:(OFString*)girFile intoDictionary:(OFDictionary**)girDict;
{
    *girDict = nil;

    OFString* girContents = [[OFString alloc] initWithContentsOfFile:girFile];

    if (girContents == nil) {
        @throw [[OFReadFailedException alloc] initWithObject:girFile requestedLength:0 errNo:0];
    }

    @try {
        // Parse the XML into a dictionary
        *girDict = [XMLReader dictionaryForXMLString:girContents];
    }
    @catch (id exception) {
        // On error, if a dictionary was still created, clean it up before returning
        if (*girDict != nil) {
            [*girDict release];
        }

        @throw exception;
    }
}

+ (GIRApi*)firstApiFromDictionary:(OFDictionary*)girDict
{
    if (girDict == nil)
        @throw [OGTKNoGIRDictException exception];

    for (OFString* key in girDict) {
        id value = [girDict objectForKey:key];

        if ([key isEqual:@"api"] || [key isEqual:@"repository"]) {
            return [[[GIRApi alloc] initWithDictionary:value] autorelease];
        } else if ([value isKindOfClass:[OFDictionary class]]) {
            return [Gir2Objc firstApiFromDictionary:value];
        }
    }

    return nil;
}

+ (GIRApi*)firstApiFromGirFile:(OFString*)girFile
{
    OFDictionary* girDict = nil;

    [Gir2Objc parseGirFromFile:girFile intoDictionary:&girDict];

    return [Gir2Objc firstApiFromDictionary:girDict];
}

+ (void)generateClassFilesFromApi:(GIRApi*)api
{
    OFArray* namespaces = api.namespaces;

    if (api == nil || namespaces == nil)
        @throw [OGTKNoGIRAPIException exception];

    for (GIRNamespace* ns in namespaces) {
        [Gir2Objc generateClassFilesFromNamespace:ns];
    }
}

+ (void)generateClassFilesFromNamespace:(GIRNamespace*)ns
{
    int i = 0;

    if (ns == nil)
        @throw [OGTKNoGIRAPIException exception];

    // Pre-load arrTrimMethodName (in GTKUtil) from info in classesToGen
    // In order to do this we must convert from something like
    // ScaleButton to gtk_scale_button
    for (GIRClass* clazz in ns.classes) {
        OFMutableString* result = [[OFMutableString alloc] init];

        for (i = 0; i < [clazz.name length]; i++) {
            // Current character
            OFString* currentChar = [clazz.name substringWithRange:OFRangeMake(i, 1)];

            if (i != 0 && [OGTKUtil isUppercase:currentChar]) {
                [result appendFormat:@"_%@", [currentChar lowercaseString]];
            } else {
                [result appendString:[currentChar lowercaseString]];
            }
        }

        [OGTKUtil addToTrimMethodName:[OFString stringWithFormat:@"gtk_%@", result]];
    }

    for (GIRClass* clazz in ns.classes) {
        OGTKClass* cgtkClass = [[OGTKClass alloc] init];

        // Set basic class properties
        [cgtkClass setCName:clazz.name];
        [cgtkClass setCType:clazz.cType];
        [cgtkClass setCParentType:clazz.parent];

        // Set constructors
        for (GIRConstructor* ctor in clazz.constructors) {
            bool foundVarArgs = false;

            // First need to check for varargs in list of parameters
            for (GIRParameter* param in ctor.parameters) {
                if (param.varargs != nil) {
                    foundVarArgs = true;
                    break;
                }
            }

            // Don't handle VarArgs constructors
            if (!foundVarArgs) {
                OGTKMethod* objcCtor = [[OGTKMethod alloc] init];
                [objcCtor setCName:ctor.cIdentifier];
                [objcCtor setCReturnType:ctor.returnValue.type.cType];

                OFMutableArray* paramArray = [[OFMutableArray alloc] init];
                for (GIRParameter* param in ctor.parameters) {
                    OGTKParameter* objcParam = [[OGTKParameter alloc] init];

                    if (param.type == nil && param.array != nil) {
                        [objcParam setCType:param.array.cType];
                    } else {
                        [objcParam setCType:param.type.cType];
                    }

                    [objcParam setCName:param.name];
                    [paramArray addObject:objcParam];
                    [objcParam release];
                }
                [objcCtor setParameters:paramArray];
                [paramArray release];

                [cgtkClass addConstructor:objcCtor];
                [objcCtor release];
            }
        }

        // Set functions
        for (GIRFunction* func in clazz.functions) {
            bool foundVarArgs = false;

            // First need to check for varargs in list of parameters
            for (GIRParameter* param in func.parameters) {
                if (param.varargs != nil) {
                    foundVarArgs = true;
                    break;
                }
            }

            if (!foundVarArgs) {
                OGTKMethod* objcFunc = [[OGTKMethod alloc] init];
                [objcFunc setCName:func.cIdentifier];

                if (func.returnValue.type == nil && func.returnValue.array != nil) {
                    [objcFunc setCReturnType:func.returnValue.array.cType];
                } else {
                    [objcFunc setCReturnType:func.returnValue.type.cType];
                }

                OFMutableArray* paramArray = [[OFMutableArray alloc] init];
                for (GIRParameter* param in func.parameters) {
                    OGTKParameter* objcParam = [[OGTKParameter alloc] init];

                    if (param.type == nil && param.array != nil) {
                        [objcParam setCType:param.array.cType];
                    } else {
                        [objcParam setCType:param.type.cType];
                    }

                    [objcParam setCName:param.name];
                    [paramArray addObject:objcParam];
                    [objcParam release];
                }
                [objcFunc setParameters:paramArray];
                [paramArray release];

                [cgtkClass addFunction:objcFunc];
                [objcFunc release];
            }
        }

        // Set methods
        for (GIRMethod* meth in clazz.methods) {
            bool foundVarArgs = false;

            // First need to check for varargs in list of parameters
            for (GIRParameter* param in meth.parameters) {
                if (param.varargs != nil) {
                    foundVarArgs = true;
                    break;
                }
            }

            if (!foundVarArgs) {
                OGTKMethod* objcMeth = [[OGTKMethod alloc] init];
                [objcMeth setCName:meth.cIdentifier];

                if (meth.returnValue.type == nil && meth.returnValue.array != nil) {
                    [objcMeth setCReturnType:meth.returnValue.array.cType];
                } else {
                    [objcMeth setCReturnType:meth.returnValue.type.cType];
                }

                OFMutableArray* paramArray = [[OFMutableArray alloc] init];
                for (GIRParameter* param in meth.parameters) {
                    OGTKParameter* objcParam = [[OGTKParameter alloc] init];

                    if (param.type == nil && param.array != nil) {
                        [objcParam setCType:param.array.cType];
                    } else {
                        [objcParam setCType:param.type.cType];
                    }

                    [objcParam setCName:param.name];
                    [paramArray addObject:objcParam];
                    [objcParam release];
                }
                [objcMeth setParameters:paramArray];
                [paramArray release];

                [cgtkClass addMethod:objcMeth];
                [objcMeth release];
            }
        }

        [OGTKClassWriter generateFilesForClass:cgtkClass inDir:[OGTKUtil globalConfigValueFor:@"outputDir"]];

        [cgtkClass release];
    }
}

@end
