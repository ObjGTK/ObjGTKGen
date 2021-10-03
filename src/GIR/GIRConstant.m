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

@synthesize cType = _cType;
@synthesize name = _name;
@synthesize theValue = _theValue;
@synthesize version = _version;
@synthesize deprecatedVersion = _deprecatedVersion;
@synthesize deprecated = _deprecated;
@synthesize doc = _doc;
@synthesize docDeprecated = _docDeprecated;
@synthesize type = _type;

- (instancetype)init
{
    self = [super init];

    @try {
        _elementTypeName = @"GIRConstant";
    } @catch (id e) {
        [self release];
        @throw e;
    }

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
            self.doc = [[[GIRDoc alloc] initWithDictionary:value] autorelease];
        } else if ([key isEqual:@"doc-deprecated"]) {
            self.docDeprecated =
                [[[GIRDoc alloc] initWithDictionary:value] autorelease];
        } else if ([key isEqual:@"type"]) {
            self.type =
                [[[GIRType alloc] initWithDictionary:value] autorelease];
        } else {
            [self logUnknownElement:key];
        }
    }
}

- (void)dealloc
{
    [_cType release];
    [_name release];
    [_theValue release];
    [_version release];
    [_deprecatedVersion release];
    [_doc release];
    [_docDeprecated release];
    [_type release];

    [super dealloc];
}

@end
