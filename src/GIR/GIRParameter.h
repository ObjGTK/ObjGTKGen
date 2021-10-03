/*
 * GIRParameter.h
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

#import <ObjFW/ObjFW.h>

#import "GIRArray.h"
#import "GIRBase.h"
#import "GIRDoc.h"
#import "GIRType.h"
#import "GIRVarargs.h"

@interface GIRParameter : GIRBase {
    OFString* _name;
    OFString* _transferOwnership;
    OFString* _direction;
    OFString* _scope;
    bool _allowNone;
    bool _callerAllocates;
    long _closure;
    long _destroy;
    GIRDoc* _doc;
    GIRType* _type;
    GIRArray* _array;
    GIRVarargs* _varargs;
}

@property (nonatomic, retain) OFString* name;
@property (nonatomic, retain) OFString* transferOwnership;
@property (nonatomic, retain) OFString* direction;
@property (nonatomic, retain) OFString* scope;
@property (nonatomic) bool allowNone;
@property (nonatomic) bool callerAllocates;
@property (nonatomic) long closure;
@property (nonatomic) long destroy;
@property (nonatomic, retain) GIRDoc* doc;
@property (nonatomic, retain) GIRType* type;
@property (nonatomic, retain) GIRArray* array;
@property (nonatomic, retain) GIRVarargs* varargs;

@end
