/*
 * OGTKClass.h
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

#include <ObjFW/OFSet.h>
#import <ObjFW/ObjFW.h>
#import "OGTKMethod.h"

@class OGTKMethod;

/**
 * Abstracts Class operations
 */
@interface OGTKClass : OFObject {
    OFString* _cName;
    OFString* _cType;
    OFString* _parentName;
    OFString* _cParentType;
    OFString* _cSymbolPrefix;
    OFString* _cNSSymbolPrefix;
    OFString* _cNSIdentifierPrefix;
    OFMutableArray* _constructors;
    OFMutableArray* _functions;
    OFMutableArray* _methods;
    OFMutableSet* _dependsOnClasses;
    OFMutableSet* _forwardDeclarationForClasses;

@private
    OFString* _typeWithoutPrefix;
}

@property (copy, nonatomic) OFString* cName;
@property (copy, nonatomic) OFString* cType;
@property (readonly, nonatomic) OFString* type;
@property (copy, nonatomic) OFString* parentName;
@property (copy, nonatomic) OFString* cParentType;
@property (copy, nonatomic) OFString* cSymbolPrefix;
@property (copy, nonatomic) OFString* cNSSymbolPrefix;
@property (copy, nonatomic) OFString* cNSIdentifierPrefix;
@property (readonly, nonatomic) OFArray* constructors;
@property (readonly, nonatomic) bool hasConstructors;
@property (readonly, nonatomic) OFArray* functions;
@property (readonly, nonatomic) bool hasFunctions;
@property (readonly, nonatomic) OFArray* methods;
@property (readonly, nonatomic) bool hasMethods;
@property (readonly, nonatomic) OFMutableSet* dependsOnClasses;
@property (readonly, nonatomic) OFMutableSet* forwardDeclarationForClasses;

- (void)addConstructor:(OGTKMethod*)ctor;
- (void)addFunction:(OGTKMethod*)fun;
- (void)addMethod:(OGTKMethod*)meth;
- (void)addDependency:(OFString*)className;

@end
