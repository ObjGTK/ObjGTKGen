/*
 * OGTKCallbackData.m
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

#import "OGTKCallbackData.h"

@implementation OGTKCallbackData
@synthesize object = _object, selector = _selector;

+ (instancetype)callbackWithObject:(id)object selector:(SEL)selector
{
    return [[[OGTKCallbackData alloc] initWithObject:object
                                            selector:selector] autorelease];
}

- (instancetype)initWithObject:(id)object selector:(SEL)selector
{
    self = [super init];

    _object = [object retain];
    _selector = selector;

    return self;
}

- (void)dealloc
{
    [_object release];

    [super dealloc];
}

@end
