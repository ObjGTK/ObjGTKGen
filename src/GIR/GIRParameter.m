/*
 * GIRParameter.m
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

#import "GIRParameter.h"

@implementation GIRParameter

@synthesize name;
@synthesize transferOwnership;
@synthesize direction;
@synthesize scope;
@synthesize allowNone;
@synthesize callerAllocates;
@synthesize closure;
@synthesize destroy;
@synthesize doc;
@synthesize type;
@synthesize array;
@synthesize varargs;

- (id)init
{
    self = [super init];

    elementTypeName = @"GIRParameter";

    return self;
}

- (id)initWithDictionary:(OFDictionary*)dict
{
    self = [self init];

    @try {
        [self parseDictionary:dict];
    } @catch (id e) {
        [self release];
        @throw e;
    }

    return self;
}

- (void)parseDictionary:(OFDictionary*)dict
{
    for (OFString* key in dict) {
        id value = [dict objectForKey:key];

        // TODO: Check if we need nullable or optional
        if ([key isEqual:@"text"] || [key isEqual:@"nullable"] ||
            [key isEqual:@"optional"]) {
            // Do nothing
        } else if ([key isEqual:@"name"]) {
            self.name = value;
        } else if ([key isEqual:@"transfer-ownership"]) {
            self.transferOwnership = value;
        } else if ([key isEqual:@"direction"]) {
            self.direction = value;
        } else if ([key isEqual:@"scope"]) {
            self.scope = value;
        } else if ([key isEqual:@"allow-none"]) {
            self.allowNone = [value isEqual:@"1"];
        } else if ([key isEqual:@"caller-allocates"]) {
            self.callerAllocates = [value isEqual:@"1"];
        } else if ([key isEqual:@"closure"]) {
            self.closure = [value longLongValue];
        } else if ([key isEqual:@"destroy"]) {
            self.destroy = [value longLongValue];
        } else if ([key isEqual:@"doc"]) {
            self.doc = [[[GIRDoc alloc] initWithDictionary:value] autorelease];
        } else if ([key isEqual:@"type"]) {
            self.type =
                [[[GIRType alloc] initWithDictionary:value] autorelease];
        } else if ([key isEqual:@"array"]) {
            self.array =
                [[[GIRArray alloc] initWithDictionary:value] autorelease];
        } else if ([key isEqual:@"varargs"]) {
            self.varargs =
                [[[GIRVarargs alloc] initWithDictionary:value] autorelease];
        } else {
            [self logUnknownElement:key];
        }
    }
}

- (void)dealloc
{
    [name release];
    [transferOwnership release];
    [direction release];
    [scope release];
    [doc release];
    [type release];
    [array release];
    [varargs release];
    [super dealloc];
}

@end
