/*
 * OGTKMapper.h
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

#import "OGTKClass.h"
#import <ObjFW/ObjFW.h>

@class OGTKClass;

/**
 * Reflects class/type mappings
 */
@interface OGTKMapper : OFObject {
    OFMutableDictionary* _gobjToObjcStringMapping;
    OFMutableDictionary* _nameToObjcStringMapping;
    OFMutableDictionary* _objcToGobjClassMapping;
}

@property (readonly, nonatomic) OFMutableDictionary* gobjToObjcStringMapping;
@property (readonly, nonatomic) OFMutableDictionary* nameToObjcStringMapping;
@property (readonly, nonatomic) OFMutableDictionary* objcToGobjClassMapping;

+ (instancetype)sharedMapper;

- (void)addClass:(OGTKClass*)clazz;

- (void)determineDependencies;

- (bool)isGobjType:(OFString*)type;

- (bool)isObjcType:(OFString*)type;

- (OFString*)swapTypes:(OFString*)type;

- (bool)isTypeSwappable:(OFString*)type;

- (OFString*)convertType:(OFString*)fromType
                withName:(OFString*)name
                  toType:(OFString*)toType;

- (OFString*)selfTypeMethodCall:(OFString*)type;

- (OFString*)getCTypeFromName:(OFString*)name;

+ (bool)isGobjType:(OFString*)type;

+ (bool)isObjcType:(OFString*)type;

/**
 * Attempts to swap the type or returns the input if it can't (shorthand
 * singleton access)
 */
+ (OFString*)swapTypes:(OFString*)type;

+ (bool)isTypeSwappable:(OFString*)type;

+ (OFString*)convertType:(OFString*)fromType
                withName:(OFString*)name
                  toType:(OFString*)toType;

/**
 * Returns the appropriate self referencing call for the type (i.e. -(type)[self
 * TYPE] or GTK_TYPE([self GOBJECT])
 */
+ (OFString*)selfTypeMethodCall:(OFString*)type;

+ (OFString*)getCTypeFromName:(OFString*)name;

@end
