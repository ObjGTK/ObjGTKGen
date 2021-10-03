/*
 * GIRNamespace.m
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

#import "GIRNamespace.h"

@implementation GIRNamespace

@synthesize name;
@synthesize cSymbolPrefixes = _cSymbolPrefixes;
@synthesize cIdentifierPrefixes = _cIdentifierPrefixes;
@synthesize classes = _classes;
@synthesize functions = _functions;
@synthesize enumerations = _enumerations;
@synthesize constants = _constants;
@synthesize interfaces = _interfaces;

- (instancetype)init
{
    self = [super init];

    @try {
        _elementTypeName = @"GIRNamespace";
        _classes = [[OFMutableArray alloc] init];
        _functions = [[OFMutableArray alloc] init];
        _enumerations = [[OFMutableArray alloc] init];
        _constants = [[OFMutableArray alloc] init];
        _interfaces = [[OFMutableArray alloc] init];
    } @catch (id e) {
        [self release];
        @throw e;
    }

    return self;
}

- (instancetype)initWithDictionary:(OFDictionary*)dict
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

        if ([key isEqual:@"text"] || [key isEqual:@"shared-library"] ||
            [key isEqual:@"version"] || [key isEqual:@"record"] ||
            [key isEqual:@"callback"] || [key isEqual:@"bitfield"] ||
            [key isEqual:@"alias"] || [key isEqual:@"function-macro"]) {
            // Do nothing
        } else if ([key isEqual:@"name"]) {
            self.name = value;
        } else if ([key isEqual:@"c:symbol-prefixes"]) {
            self.cSymbolPrefixes = value;
        } else if ([key isEqual:@"c:identifier-prefixes"]) {
            self.cIdentifierPrefixes = value;
        } else if ([key isEqual:@"class"]) {
            [self processArrayOrDictionary:value
                                 withClass:[GIRClass class]
                                  andArray:_classes];
        } else if ([key isEqual:@"function"]) {
            [self processArrayOrDictionary:value
                                 withClass:[GIRFunction class]
                                  andArray:_functions];
        } else if ([key isEqual:@"enumeration"]) {
            [self processArrayOrDictionary:value
                                 withClass:[GIREnumeration class]
                                  andArray:_enumerations];
        } else if ([key isEqual:@"constant"]) {
            [self processArrayOrDictionary:value
                                 withClass:[GIRConstant class]
                                  andArray:_constants];
        } else if ([key isEqual:@"interface"]) {
            [self processArrayOrDictionary:value
                                 withClass:[GIRInterface class]
                                  andArray:_interfaces];
        } else {
            [self logUnknownElement:key];
        }
    }
}

- (void)dealloc
{
    [_name release];
    [_cSymbolPrefixes release];
    [_cIdentifierPrefixes release];
    [_classes release];
    [_functions release];
    [_enumerations release];
    [_constants release];
    [_interfaces release];

    [super dealloc];
}

@end
