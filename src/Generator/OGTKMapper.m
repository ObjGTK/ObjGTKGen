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

static OGTKMapper* sharedMyMapper = nil;

@implementation OGTKMapper

@synthesize gobjToObjcStringMapping = _gobjToObjcStringMapping,
            objcToGobjClassMapping = _objcToGobjClassMapping;

- (instancetype)init
{
    self = [super init];

    @try {
        _gobjToObjcStringMapping = [[OFMutableDictionary alloc] init];
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

- (void)calculateDependencies
{
}

- (OFString*)swapTypes:(OFString*)type
{
    // Convert basic types by hardcoding
    if ([type isEqual:@"Atk.Object"] || [type isEqual:@"Gio.Application"] ||
        [type isEqual:@"GObject.InitiallyUnowned"] ||
        [type isEqual:@"GObject.Object"])
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
    return [type isEqual:@"OFArray*"] || [self isGobjType:type] ||
        [self isObjcType:type];
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

@end