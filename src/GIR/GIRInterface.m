/*
 * GIRInterface.m
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

#import "GIRInterface.h"

@implementation GIRInterface

@synthesize name;
@synthesize cType;
@synthesize cSymbolPrefix;
@synthesize doc;
@synthesize fields;
@synthesize methods;
@synthesize virtualMethods;
@synthesize properties;
@synthesize prerequisite;

- (id)init
{
    self = [super init];

    self.elementTypeName = @"GIRInterface";
    self.fields = [[OFMutableArray alloc] init];
    self.methods = [[OFMutableArray alloc] init];
    self.virtualMethods = [[OFMutableArray alloc] init];
    self.properties = [[OFMutableArray alloc] init];

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

        if ([key isEqual:@"text"]
            || [key isEqual:@"glib:type-name"]
            || [key isEqual:@"glib:type-struct"]
            || [key isEqual:@"glib:signal"]
            || [key isEqual:@"glib:get-type"]) {
            // Do nothing
        } else if ([key isEqual:@"name"]) {
            self.name = value;
        } else if ([key isEqual:@"c:type"]) {
            self.cType = value;
        } else if ([key isEqual:@"c:symbol-prefix"]) {
            self.cSymbolPrefix = value;
        } else if ([key isEqual:@"doc"]) {
            self.doc = [[GIRDoc alloc] initWithDictionary:value];
        } else if ([key isEqual:@"fields"]) {
            [self processArrayOrDictionary:value withClass:[GIRField class] andArray:fields];
        } else if ([key isEqual:@"method"]) {
            [self processArrayOrDictionary:value withClass:[GIRMethod class] andArray:methods];
        } else if ([key isEqual:@"virtual-method"]) {
            [self processArrayOrDictionary:value withClass:[GIRVirtualMethod class] andArray:virtualMethods];
        } else if ([key isEqual:@"property"]) {
            [self processArrayOrDictionary:value withClass:[GIRProperty class] andArray:properties];
        } else if ([key isEqual:@"prerequisite"]) {
            self.prerequisite = [[GIRPrerequisite alloc] initWithDictionary:value];
        } else {
            [self logUnknownElement:key];
        }
    }
}

- (void)dealloc
{
    [name release];
    [cType release];
    [cSymbolPrefix release];
    [doc release];
    [fields release];
    [methods release];
    [virtualMethods release];
    [properties release];
    [prerequisite release];
    [super dealloc];
}

@end
