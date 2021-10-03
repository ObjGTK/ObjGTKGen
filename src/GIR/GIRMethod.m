/*
 * GIRMethod.m
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

#import "GIRMethod.h"

@implementation GIRMethod

@synthesize name;
@synthesize cIdentifier;
@synthesize version;
@synthesize returnValue;
@synthesize doc;
@synthesize docDeprecated;
@synthesize deprecated;
@synthesize deprecatedVersion;
@synthesize invoker;
@synthesize throws;
@synthesize introspectable;
@synthesize shadowedBy;
@synthesize shadows;
@synthesize parameters;
@synthesize instanceParameters;

- (id)init
{
    self = [super init];

    elementTypeName = @"GIRMethod";
    parameters = [OFMutableArray array];
    instanceParameters = [OFMutableArray array];

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

        if (![self tryParseWithKey:key andValue:value]) {
            [self logUnknownElement:key];
        }
    }
}

- (bool)tryParseWithKey:(OFString*)key andValue:(id)value
{
    if ([key isEqual:@"text"] || [key isEqual:@"source-position"]) {
        // Do nothing
    } else if ([key isEqual:@"name"]) {
        self.name = value;
    } else if ([key isEqual:@"c:identifier"]) {
        self.cIdentifier = value;
    } else if ([key isEqual:@"version"]) {
        self.version = value;
    } else if ([key isEqual:@"return-value"]) {
        self.returnValue =
            [[[GIRReturnValue alloc] initWithDictionary:value] autorelease];
    } else if ([key isEqual:@"doc"]) {
        self.doc = [[[GIRDoc alloc] initWithDictionary:value] autorelease];
    } else if ([key isEqual:@"doc-deprecated"]) {
        self.docDeprecated =
            [[[GIRDoc alloc] initWithDictionary:value] autorelease];
    } else if ([key isEqual:@"deprecated"]) {
        self.deprecated = [value isEqual:@"1"];
    } else if ([key isEqual:@"deprecated-version"]) {
        self.deprecatedVersion = value;
    } else if ([key isEqual:@"invoker"]) {
        self.invoker = value;
    } else if ([key isEqual:@"throws"]) {
        self.throws = [value isEqual:@"1"];
    } else if ([key isEqual:@"introspectable"]) {
        self.introspectable = [value isEqual:@"1"];
    } else if ([key isEqual:@"shadowed-by"]) {
        self.shadowedBy = [value isEqual:@"1"];
    } else if ([key isEqual:@"shadows"]) {
        self.shadows = [value isEqual:@"1"];
    } else if ([key isEqual:@"parameters"]) {
        for (OFString* paramKey in value) {
            if ([paramKey isEqual:@"parameter"]) {
                [self processArrayOrDictionary:[value objectForKey:paramKey]
                                     withClass:[GIRParameter class]
                                      andArray:parameters];
            } else if ([paramKey isEqual:@"instance-parameter"]) {
                [self processArrayOrDictionary:[value objectForKey:paramKey]
                                     withClass:[GIRParameter class]
                                      andArray:instanceParameters];
            }
        }
    } else {
        return false;
    }

    return true;
}

- (void)dealloc
{
    [name release];
    [cIdentifier release];
    [version release];
    [returnValue release];
    [deprecatedVersion release];
    [invoker release];
    [doc release];
    [docDeprecated release];
    [parameters release];
    [instanceParameters release];
    [super dealloc];
}

@end
