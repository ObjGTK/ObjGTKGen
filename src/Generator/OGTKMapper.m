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

    OFString* swappedType = [_gobjToObjcStringMapping objectForKey:strippedType];
    if(swappedType != nil) {
        if([strippedType isEqual:type])
            return swappedType;
        else
            return [OFString stringWithFormat:@"%@*", swappedType];
    }

    OGTKClass* swappedClass = [_objcToGobjClassMapping objectForKey:strippedType];
    if(swappedClass != nil) {
        if([strippedType isEqual:type])
            return swappedClass.cType;
        else
            return [OFString stringWithFormat:@"%@*", swappedClass.cType];
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

@end