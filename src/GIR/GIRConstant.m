/*
 * GIRConstant.m
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

#import "GIRConstant.h"

@implementation GIRConstant

@synthesize cType;
@synthesize name;
@synthesize theValue;
@synthesize version;
@synthesize deprecatedVersion;
@synthesize deprecated;
@synthesize doc;
@synthesize docDeprecated;
@synthesize type;

- (id)init
{
    self = [super init];

    @try {
        elementTypeName = @"GIRConstant";
    } @catch (id e) {
        [self release];
        @throw e;
    }

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

        if ([key isEqual:@"text"] || [key isEqual:@"type"] ||
            [key isEqual:@"source-position"]) {
            // Do nothing
        } else if ([key isEqual:@"c:type"]) {
            self.cType = value;
        } else if ([key isEqual:@"name"]) {
            self.name = value;
        } else if ([key isEqual:@"value"]) {
            self.theValue = value;
        } else if ([key isEqual:@"version"]) {
            self.version = value;
        } else if ([key isEqual:@"deprecated-version"]) {
            self.deprecatedVersion = value;
        } else if ([key isEqual:@"deprecated"]) {
            self.deprecated = [value isEqual:@"1"];
        } else if ([key isEqual:@"doc"]) {
            self.doc = [[GIRDoc alloc] initWithDictionary:value];
        } else if ([key isEqual:@"doc-deprecated"]) {
            self.docDeprecated = [[GIRDoc alloc] initWithDictionary:value];
        } else if ([key isEqual:@"type"]) {
            self.type = [[GIRType alloc] initWithDictionary:value];
        } else {
            [self logUnknownElement:key];
        }
    }
}

- (void)dealloc
{
    [cType release];
    [name release];
    [theValue release];
    [version release];
    [deprecatedVersion release];
    [doc release];
    [docDeprecated release];
    [type release];
    [super dealloc];
}

@end
