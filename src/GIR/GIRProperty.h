/*
 * GIRProperty.h
 * This file is part of ObjGTK
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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 */

#import <ObjFW/ObjFW.h>

#import "GIRArray.h"
#import "GIRBase.h"
#import "GIRDoc.h"
#import "GIRType.h"

@interface GIRProperty : GIRBase {
    OFString* name;
    OFString* transferOwnership;
    OFString* version;
    OFString* deprecatedVersion;
    GIRDoc* doc;
    GIRDoc* docDeprecated;
    GIRType* type;
    bool allowNone;
    bool constructOnly;
    bool readable;
    bool deprecated;
    OFString* construct;
    OFString* writable;
    GIRArray* array;
}

@property (nonatomic, retain) OFString* name;
@property (nonatomic, retain) OFString* transferOwnership;
@property (nonatomic, retain) OFString* version;
@property (nonatomic, retain) OFString* deprecatedVersion;
@property (nonatomic, retain) GIRDoc* doc;
@property (nonatomic, retain) GIRDoc* docDeprecated;
@property (nonatomic, retain) GIRType* type;
@property (nonatomic) bool allowNone;
@property (nonatomic) bool constructOnly;
@property (nonatomic) bool readable;
@property (nonatomic) bool deprecated;
@property (nonatomic, retain) OFString* construct;
@property (nonatomic, retain) OFString* writable;
@property (nonatomic, retain) GIRArray* array;

@end
