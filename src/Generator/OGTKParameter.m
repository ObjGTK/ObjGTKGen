/*
 * OGTKParameter.m
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

#import "OGTKParameter.h"

/**
 * Abstracts Parameter operations
 */
@implementation OGTKParameter

- (id)init
{
    self = [super init];

    return self;
}

- (void)setCType:(OFString*)type
{
    if (cType != nil) {
        [cType release];
    }

    if (type == nil) {
        cType = nil;
    } else {
        cType = [type retain];
    }
}

- (OFString*)cType
{
    return [[cType retain] autorelease];
}

- (OFString*)type
{
    return [OGTKUtil swapTypes:[self cType]];
}

- (void)setCName:(OFString*)name
{
    if (cName != nil) {
        [cName release];
    }

    if (name == nil) {
        cName = nil;
    } else {
        cName = [name retain];
    }
}

- (OFString*)cName
{
    return [[cName retain] autorelease];
}

- (OFString*)name
{
    return [OGTKUtil convertUSSToCamelCase:cName];
}

- (void)dealloc
{
    [cType release];
    [cName release];
    [super dealloc];
}

@end
