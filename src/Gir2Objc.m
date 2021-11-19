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

@implementation Gir2Objc

+ (void)parseGirFromFile:(OFString*)girFile
          intoDictionary:(OFDictionary**)girDict;
{
    *girDict = nil;

    OFString* girContents =
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
        // On error, if a dictionary was still created, clean it up before
        // returning
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
    if (ns == nil)
        @throw [OGTKNoGIRAPIException exception];

    OFLog(@"Namespace name: %@", ns.name);
    OFLog(@"C symbol prefix: %@", ns.cSymbolPrefixes);
    OFLog(@"C identifier prefix: %@", ns.cIdentifierPrefixes);

    OGTKMapper* sharedMapper = [OGTKMapper sharedMapper];

    for (GIRClass* clazz in ns.classes) {
        @autoreleasepool {
            OGTKClass* cgtkClass = [[[OGTKClass alloc] init] autorelease];

            // Set basic class properties
            [cgtkClass setCName:clazz.name];
            [cgtkClass setCType:clazz.cType];

            // Set parent name
            [cgtkClass setParentName:clazz.parent];

            // Try to set parent c type
            // First try to get information from a <field> node.
            // Otherwise we need to get the c type from the mapper later
            OFArray* classFields = clazz.fields;
            for (GIRField* field in classFields) {
                if ([field.name isEqual:@"parent_class"] ||
                    [field.name isEqual:@"parent_instance"]) {
                    [cgtkClass setCParentType:field.type.cType];
                }
            }

            [cgtkClass setCSymbolPrefix:clazz.cSymbolPrefix];
            [cgtkClass setCNSIdentifierPrefix:ns.cIdentifierPrefixes];
            [cgtkClass setCNSSymbolPrefix:ns.cSymbolPrefixes];

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
                    [objcCtor setName:ctor.name];
                    [objcCtor setCIdentifier:ctor.cIdentifier];
                    [objcCtor setCReturnType:ctor.returnValue.type.cType];
                    [objcCtor setThrows:ctor.throws];

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
                    [objcFunc setName:func.name];
                    [objcFunc setCIdentifier:func.cIdentifier];
                    [objcFunc setThrows:func.throws];

                    if (func.returnValue.type == nil
                        && func.returnValue.array != nil) {
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
                    [objcMeth setName:meth.name];
                    [objcMeth setCIdentifier:meth.cIdentifier];
                    [objcMeth setThrows:meth.throws];

                    if (meth.returnValue.type == nil
                        && meth.returnValue.array != nil) {
                        [objcMeth setCReturnType:meth.returnValue.array.cType];
                    } else {
                        [objcMeth setCReturnType:meth.returnValue.type.cType];
                    }

                    OFMutableArray* paramArray = [OFMutableArray array];
                    for (GIRParameter* param in meth.parameters) {
                        OGTKParameter* objcParam =
                            [[[OGTKParameter alloc] init] autorelease];

                        if (param.type == nil && param.array != nil) {
                            [objcParam setCType:param.array.cType];
                        } else {
                            [objcParam setCType:param.type.cType];
                        }

                        [objcParam setCName:param.name];
                        [paramArray addObject:objcParam];
                    }
                    [objcMeth setParameters:paramArray];

                    [cgtkClass addMethod:objcMeth];
                    [objcMeth release];
                }
            }

            @try {
                [sharedMapper addClass:cgtkClass];
            } @catch (id e) {
                OFLog(@"Warning: Cannot add type %@ to mapper. "
                      @"Exception %@, description: %@"
                      @"Class definition may be incorrect. Skipping…",
                    cgtkClass.cName, [e class], [e description]);
            }
        }
    }

    // Set correct class names for parent classes
    OFMutableDictionary* classesDict = sharedMapper.objcTypeToClassMapping;

    for (OFString* className in classesDict) {
        OGTKClass* currentClass = [classesDict objectForKey:className];

        if (currentClass.cParentType == nil) {
            @try {
                [currentClass
                    setCParentType:[OGTKMapper
                                       getCTypeFromName:currentClass
                                                            .parentName]];
            } @catch (id e) {
                OFLog(@"Could not get c type for parent of %@, exception %@. "
                      @"Skipping…",
                    currentClass.cName, [e class]);
            }
        }
    }

    // Calculate dependencies for each class
    [sharedMapper determineDependencies];

    // Set flags for fast necessary forward class definitions.
    [sharedMapper detectAndMarkCircularDependencies];

    // TODO
    // 2. Write a concluding header file and a make file importing all the classes

    // Write the classes
    for (OFString* className in classesDict) {
        [OGTKClassWriter
            generateFilesForClass:[classesDict objectForKey:className]
                            inDir:[OGTKUtil globalConfigValueFor:@"outputDir"]];
    }
}

@end
