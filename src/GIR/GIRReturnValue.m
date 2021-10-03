/*
 * GIRReturnValue.m
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

#import "GIRReturnValue.h"

@implementation GIRReturnValue

@synthesize transferOwnership;
@synthesize doc;
@synthesize type;
@synthesize array;

- (id)init
{
    self = [super init];

    elementTypeName = @"GIRReturnValue";

    return self;
}

- (id)initWithDictionary:(OFDictionary*)dict
{
    self = [self init];

    [self parseDictionary:dict];

    return self;
}

- (void)parseDictionary:(OFDictionary*)dict
{
    for (OFString* key in dict) {
        id value = [dict objectForKey:key];

        // TODO: Do we nee nullable?
        if ([key isEqual:@"text"] || [key isEqual:@"nullable"]) {
            // Do nothing
        } else if ([key isEqual:@"transfer-ownership"]) {
            self.transferOwnership = value;
        } else if ([key isEqual:@"doc"]) {
            self.doc = [[GIRDoc alloc] initWithDictionary:value];
        } else if ([key isEqual:@"type"]) {
            self.type = [[GIRType alloc] initWithDictionary:value];
        } else if ([key isEqual:@"array"]) {
            self.array = [[GIRArray alloc] initWithDictionary:value];
        } else {
            [self logUnknownElement:key];
        }
    }
}

- (void)dealloc
{
    [transferOwnership release];
    [doc release];
    [type release];
    [array release];
    [super dealloc];
}

@end
