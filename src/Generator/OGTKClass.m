/*
 * OGTKClass.m
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
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 */

/*
 * Objective-C imports
 */
#import "OGTKClass.h"

@implementation OGTKClass
@synthesize cName = _cName, cType = _cType, cParentType = _cParentType,
            cSymbolPrefix = _cSymbolPrefix,
            cIdentifierPrefix = _cIdentifierPrefix,
            dependsOnClasses = _dependsOnClasses,
            forwardDeclarationForClasses = _forwardDeclarationForClasses;

- (instancetype)init
{
    self = [super init];

    @try {
        _constructors = [[OFMutableArray alloc] init];
        _functions = [[OFMutableArray alloc] init];
        _methods = [[OFMutableArray alloc] init];
        _dependsOnClasses = [[OFMutableArray alloc] init];
        _forwardDeclarationForClasses = [[OFMutableArray alloc] init];
    } @catch (id e) {
        [self release];
        @throw e;
    }

    return self;
}

- (void)dealloc
{
    [_cName release];
    [_cType release];
    [_cParentType release];
    [_cIdentifierPrefix release];
    [_cSymbolPrefix release];
    [_constructors release];
    [_functions release];
    [_methods release];
    [_dependsOnClasses release];
    [_forwardDeclarationForClasses release];

    [_typeWithoutPrefix release];

    [super dealloc];
}

- (OFString*)type
{
    if (self.cType == nil)
        @throw [OGTKReceivedNilExpectedStringException exception];

    if ([self.cIdentifierPrefix isEqual:@"Gtk"] &&
        [self.cType hasPrefix:@"Gtk"]) {

        if (_typeWithoutPrefix == nil) {
            size_t prefixLength = self.cIdentifierPrefix.length;

            _typeWithoutPrefix = [self.cType substringFromIndex:prefixLength];

            [_typeWithoutPrefix retain];
        }

        return [OFString stringWithFormat:@"OGTK%@", _typeWithoutPrefix];
    }

    return [OFString stringWithFormat:@"OG%@%@", self.cType];
}

- (OFString*)name
{
    return [OFString stringWithFormat:@"OGTK%@", _cName];
}

- (void)addConstructor:(OGTKMethod*)constructor
{
    if (constructor != nil) {
        [_constructors addObject:constructor];
    }
}

- (OFArray*)constructors
{
    return [[_constructors copy] autorelease];
}

- (bool)hasConstructors
{
    return (_constructors.count > 0);
}

- (void)addFunction:(OGTKMethod*)function
{
    if (function != nil) {
        [_functions addObject:function];
    }
}

- (OFArray*)functions
{
    return [[_functions copy] autorelease];
}

- (bool)hasFunctions
{
    return (_functions.count > 0);
}

- (void)addMethod:(OGTKMethod*)method
{
    if (method != nil) {
        [_methods addObject:method];
    }
}

- (OFArray*)methods
{
    return [[_methods copy] autorelease];
}

- (bool)hasMethods
{
    return (_methods.count > 0);
}

@end
