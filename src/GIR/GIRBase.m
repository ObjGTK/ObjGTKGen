/*
 * GIRBase.m
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

#import "GIRBase.h"

@implementation GIRBase

@synthesize elementTypeName;
@synthesize unknownElements;

LogLevel __logLevel = Info;

+ (void)setLogLevel:(LogLevel)level
{
    __logLevel = level;
}

+ (void)log:(OFString*)message andLevel:(LogLevel)level
{
    if (level >= __logLevel) {
        OFString* levelDescription = nil;

        switch (level) {
        case Debug:
            levelDescription = @"Debug";
            break;
        case Info:
            levelDescription = @"Info";
            break;
        case Warning:
            levelDescription = @"Warning";
            break;
        case Error:
            levelDescription = @"Error";
            break;
        default:
            levelDescription = @"Unkown";
            break;
        }

        OFLog(@"[%@] %@", levelDescription, message);
    }
}

- (void)parseDictionary:(OFDictionary*)dict
{
	@throw [OFNotImplementedException exceptionWithSelector:@selector(_cmd) object:self];
}

- (void)processArrayOrDictionary:(id)values withClass:(Class)clazz andArray:(OFMutableArray*)array;
{
    // If the values are a dictionary call it directly
    if ([values isKindOfClass:[OFDictionary class]]) {
        id obj = [[clazz alloc] init];

        if ([obj conformsToProtocol:@protocol(GIRParseDictionary)]) {
            [obj parseDictionary:values];
            [array addObject:obj];
        }
    } else if ([values isKindOfClass:[OFArray class]]) {
        for (id object in values) {
            [self processArrayOrDictionary:object withClass:clazz andArray:array];
        }
    }
}

- (void)logUnknownElement:(OFString*)element
{
    if (unknownElements == nil) {
        unknownElements = [[OFMutableDictionary alloc] init];
    }

    OFString* hopefullyUniqueKey = [OFString stringWithFormat:@"%@--%@", self.elementTypeName, element];

    if ([unknownElements objectForKey:hopefullyUniqueKey] != nil) {
        [unknownElements setObject:hopefullyUniqueKey forKey:hopefullyUniqueKey];
    } else {
        [GIRBase log:[OFString stringWithFormat:@"[%@]: Found unknown element: [%@]", self.elementTypeName, element] andLevel:Warning];
    }
}

- (void)dealloc
{
    [elementTypeName release];
    if (unknownElements != nil) {
        [unknownElements release];
    }
    [super dealloc];
}

@end
