/*
 * OGTKMapper.m
 * This file is part of ObjGTKGen
 *
 * Copyright (C) 2021 - Johannes Brakensiek
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

#import "OGTKMapper.h"
#import "OGTKParameter.h"
#include <ObjFW/OFDictionary.h>
#include <ObjFW/OFStdIOStream.h>

static OGTKMapper* sharedMyMapper = nil;

@implementation OGTKMapper

@synthesize gobjToObjcStringMapping = _gobjToObjcStringMapping,
            objcToGobjClassMapping = _objcToGobjClassMapping,
            nameToObjcStringMapping = _nameToObjcStringMapping;

- (instancetype)init
{
    self = [super init];

    @try {
        _gobjToObjcStringMapping = [[OFMutableDictionary alloc] init];
        _nameToObjcStringMapping = [[OFMutableDictionary alloc] init];
        _objcToGobjClassMapping = [[OFMutableDictionary alloc] init];
    } @catch (id e) {
        [self release];
        @throw e;
    }

    return self;
}

- (void)dealloc
{
    [_gobjToObjcStringMapping release];
    [_nameToObjcStringMapping release];
    [_objcToGobjClassMapping release];

    [super dealloc];
}

+ (instancetype)sharedMapper
{
    @synchronized(self) {
        if (sharedMyMapper == nil)
            sharedMyMapper = [[self alloc] init];
    }
    return sharedMyMapper;
}

- (void)addClass:(OGTKClass*)clazz
{
    [_gobjToObjcStringMapping setObject:clazz.type forKey:clazz.cType];

    [_nameToObjcStringMapping setObject:clazz.type forKey:clazz.cName];

    [_objcToGobjClassMapping setObject:clazz forKey:clazz.type];
}

- (bool)isGobjType:(OFString*)type
{
    return ([_gobjToObjcStringMapping objectForKey:[self stripAsterisks:type]]
        != nil);
}

- (bool)isObjcType:(OFString*)type
{
    return ([_objcToGobjClassMapping objectForKey:[self stripAsterisks:type]]
        != nil);
}

- (void)determineDependencies
{
    for (OFString* className in _objcToGobjClassMapping) {
        OGTKClass* classInfo = [_objcToGobjClassMapping objectForKey:className];

        if (classInfo.cParentType != nil)
            [classInfo addDependency:classInfo.cParentType];

        for (OGTKMethod* constructor in classInfo.constructors)
            [self addDependenciesFromMethod:constructor to:classInfo];

        for (OGTKMethod* function in classInfo.functions)
            [self addDependenciesFromMethod:function to:classInfo];

        for (OGTKMethod* method in classInfo.methods)
            [self addDependenciesFromMethod:method to:classInfo];
    }
}

- (void)detectAndMarkCircularDependencies
{
    for (OFString* className in _objcToGobjClassMapping) {
        OGTKClass* classInfo = [_objcToGobjClassMapping objectForKey:className];

        OFMutableDictionary* stack = [[OFMutableDictionary alloc] init];

        [stack setObject:@"1" forKey:classInfo.cType];

        [self walkDependencyTreeFrom:classInfo usingStack:stack];

        [stack release];
    }
}

// TODO: Need to add stack - otherwise we won't detect circular dependencies
// while walking through the tree :D To not do this multiple times be sure to
// check whether the forwardDeclaration already has been done
- (void)walkDependencyTreeFrom:(OGTKClass*)classInfo
                    usingStack:(OFMutableDictionary*)stack
{
    if (classInfo.visited) {
        OFLog(@"Class %@ aleady visited. Skipping…", classInfo.cType);
        return;
    }

    OFLog(@"Visiting class: %@.", classInfo.cType);
    classInfo.visited = true;

    // First follow parent classes - traverse to the topmost tree element
    OFString* parentClassObjcName = nil;

    if (classInfo.cParentType != nil)
        parentClassObjcName =
            [_gobjToObjcStringMapping objectForKey:classInfo.cParentType];

    if (parentClassObjcName != nil &&
        [stack objectForKey:classInfo.cParentType] == nil) {

        OGTKClass* parentClassInfo =
            [_objcToGobjClassMapping objectForKey:parentClassObjcName];

        [stack setObject:@"1" forKey:classInfo.cParentType];
        [self walkDependencyTreeFrom:parentClassInfo usingStack:stack];
    }

    OFLog(@"Checking dependencies of %@.", classInfo.cType);
    // Then start to follow dependencies - leave out parent classes this time
    for (OFString* dependencyGobjName in classInfo.dependsOnClasses) {

        // Add a forward declaration if the dependency is within the stack -
        // we're inside a circular dependency structure then
        if ([stack objectForKey:dependencyGobjName] != nil
            && ![classInfo.cParentType isEqual:dependencyGobjName]) {

            OFLog(
                @"Detected circular dependency %@, adding forward declaration.",
                dependencyGobjName);
            [classInfo addForwardDeclarationForClass:dependencyGobjName];

            continue;
        }

        OFString* dependencyObjcName =
            [_gobjToObjcStringMapping objectForKey:dependencyGobjName];

        if (dependencyObjcName == nil)
            continue;

        // We got a dependency to follow
        OGTKClass* dependencyClassInfo =
            [_objcToGobjClassMapping objectForKey:dependencyObjcName];

        // We are ready to visit that dependency and follow its dependencies
        [stack setObject:@"1" forKey:dependencyGobjName];

        [self walkDependencyTreeFrom:dependencyClassInfo usingStack:stack];
    }

    [classInfo removeForwardDeclarationsFromDependencies];
}

- (OFString*)swapTypes:(OFString*)type
{
    // Convert basic types by hardcoding
    if ([type isEqual:@"AtkObject"] || [type isEqual:@"GApplication"] ||
        [type isEqual:@"GInitiallyUnowned"] || [type isEqual:@"GObject"])
        return @"OGTKObject";
    else if ([type isEqual:@"const gchar*"] || [type isEqual:@"gchar*"])
        return @"OFString*";
    else if ([type isEqual:@"Gtk"])
        return @"OGTK";
    else if ([type isEqual:@"OFString*"])
        return @"const gchar*";

    // Different naming, same type
    else if ([type isEqual:@"gboolean"])
        return @"bool";
    else if ([type isEqual:@"bool"])
        return @"gboolean";

    OFString* strippedType = [self stripAsterisks:type];

    OFString* swappedType =
        [_gobjToObjcStringMapping objectForKey:strippedType];
    if (swappedType != nil) {
        if ([strippedType isEqual:type])
            return swappedType;
        else
            return [OFString stringWithFormat:@"%@*", swappedType];
    }

    OGTKClass* swappedClass =
        [_objcToGobjClassMapping objectForKey:strippedType];
    if (swappedClass != nil) {
        if ([strippedType isEqual:type])
            return swappedClass.cType;
        else
            return [OFString stringWithFormat:@"%@*", swappedClass.cType];
    }

    return type;
}

- (bool)isTypeSwappable:(OFString*)type
{
    return [type isEqual:@"gchar*"] || [type isEqual:@"const gchar*"] ||
        [type isEqual:@"OFString*"] || [type isEqual:@"OFArray*"] ||
        [self isGobjType:type] || [self isObjcType:type];
}

// TODO What about references (**)?
- (OFString*)convertType:(OFString*)fromType
                withName:(OFString*)name
                  toType:(OFString*)toType
{
    // Try to return conversion for string types first
    if (([fromType isEqual:@"gchar*"] || [fromType isEqual:@"const gchar*"]) &&
        [toType isEqual:@"OFString*"]) {
        return [OFString
            stringWithFormat:@"[OFString stringWithUTF8String:%@]", name];
    } else if ([fromType isEqual:@"OFString*"]
        && ([toType isEqual:@"gchar*"] || [toType isEqual:@"const gchar*"])) {
        return [OFString stringWithFormat:@"[%@ UTF8String]", name];
    }

    // Then try to return generic Gobj type conversion
    if ([self isGobjType:fromType] && [self isObjcType:toType]) {
        // Converting from Gobjc -> Objc

        return [OFString
            stringWithFormat:@"[[%@ alloc] initWithGObject:(GObject*)%@]",
            [self stripAsterisks:toType], name];

    } else if ([self isObjcType:fromType] && [self isGobjType:toType]) {
        // Converting from Objc -> Gobj

        OGTKClass* toClass = [_objcToGobjClassMapping
            objectForKey:[self stripAsterisks:fromType]];

        return [OFString
            stringWithFormat:@"[%@ %@]", name, [toClass.cName uppercaseString]];
    }

    // Otherwise don't do any conversion (including bool types, as ObjFW uses
    // the stdc bool type)
    return name;
}

- (OFString*)selfTypeMethodCall:(OFString*)type;
{
    // Convert OGTKFooBar into [self FOOBAR]
    if ([self isObjcType:type]) {
        OGTKClass* toClass =
            [_objcToGobjClassMapping objectForKey:[self stripAsterisks:type]];

        return [OFString
            stringWithFormat:@"[self %@]", [toClass.cName uppercaseString]];
    }

    // Convert GtkFooBar into GTK_FOO_BAR([self GOBJECT])
    if ([self isGobjType:type]) {
        OGTKClass* classInfo = [_objcToGobjClassMapping
            objectForKey:[_gobjToObjcStringMapping
                             objectForKey:[self stripAsterisks:type]]];

        OFString* functionMacroName =
            [[OFString stringWithFormat:@"%@_%@", classInfo.cNSSymbolPrefix,
                       classInfo.cSymbolPrefix] uppercaseString];

        return [OFString
            stringWithFormat:@"%@%@", functionMacroName, @"([self GOBJECT])"];
    }

    return type;
}

- (OFString*)getCTypeFromName:(OFString*)name
{
    // Some shortcut definitions from libraries we do not want to add as
    // dependencies
    if ([name isEqual:@"Atk.Object"])
        return @"AtkObject";
    else if ([name isEqual:@"Gio.Application"])
        return @"GApplication";
    else if ([name isEqual:@"GObject.InitiallyUnowned"])
        return @"GInitiallyUnowned";
    else if ([name isEqual:@"GObject.Object"])
        return @"GObject";

    // Name has a namespace prefix
    if ([name containsString:@"."]) {
        OFArray* nameParts = [name componentsSeparatedByString:@"."];

        OFString* objcType =
            [_nameToObjcStringMapping objectForKey:[nameParts objectAtIndex:1]];

        if (objcType != nil) {
            OGTKClass* classInfo =
                [_objcToGobjClassMapping objectForKey:objcType];

            if ([classInfo.cNSIdentifierPrefix
                    isEqual:[nameParts objectAtIndex:0]])
                return classInfo.cType;
        }
    }

    // Simple name without prefix
    OFString* objcType = [_nameToObjcStringMapping objectForKey:name];
    if (objcType != nil) {
        OGTKClass* classInfo = [_objcToGobjClassMapping objectForKey:objcType];
        return classInfo.cType;
    }

    // We did not find any c type
    @throw [OFInvalidArgumentException exception];
}

// Private methods
- (OFString*)stripAsterisks:(OFString*)identifier
{
    OFCharacterSet* charSet =
        [OFCharacterSet characterSetWithCharactersInString:@"*"];
    size_t index = [identifier indexOfCharacterFromSet:charSet];

    if (index == OFNotFound)
        return identifier;

    return [identifier substringToIndex:index];
}

- (void)addDependenciesFromMethod:(OGTKMethod*)method to:(OGTKClass*)classInfo
{
    OFString* strippedReturnType = [self stripAsterisks:method.cReturnType];

    if ([self isTypeSwappable:strippedReturnType]
        && ![strippedReturnType isEqual:classInfo.cType])
        [classInfo addDependency:strippedReturnType];

    for (OGTKParameter* parameter in method.parameters) {
        OFString* strippedParameterCType =
            [self stripAsterisks:parameter.cType];

        if ([self isTypeSwappable:strippedParameterCType]
            && ![strippedParameterCType isEqual:classInfo.cType])
            [classInfo addDependency:strippedParameterCType];
    }
}

// Short hands for singleton access
+ (OFString*)swapTypes:(OFString*)type
{
    OGTKMapper* sharedMapper = [OGTKMapper sharedMapper];

    return [sharedMapper swapTypes:type];
}

+ (bool)isTypeSwappable:(OFString*)type
{
    OGTKMapper* sharedMapper = [OGTKMapper sharedMapper];

    return [sharedMapper isTypeSwappable:type];
}

+ (bool)isGobjType:(OFString*)type
{
    OGTKMapper* sharedMapper = [OGTKMapper sharedMapper];

    return [sharedMapper isGobjType:type];
}

+ (bool)isObjcType:(OFString*)type
{
    OGTKMapper* sharedMapper = [OGTKMapper sharedMapper];

    return [sharedMapper isObjcType:type];
}

+ (OFString*)convertType:(OFString*)fromType
                withName:(OFString*)name
                  toType:(OFString*)toType
{
    OGTKMapper* sharedMapper = [OGTKMapper sharedMapper];

    return [sharedMapper convertType:fromType withName:name toType:toType];
}

+ (OFString*)selfTypeMethodCall:(OFString*)type
{
    OGTKMapper* sharedMapper = [OGTKMapper sharedMapper];

    return [sharedMapper selfTypeMethodCall:type];
}

+ (OFString*)getCTypeFromName:(OFString*)name
{
    OGTKMapper* sharedMapper = [OGTKMapper sharedMapper];

    return [sharedMapper getCTypeFromName:name];
}

@end