/*
 * GIRProperty.h
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

@interface GIRProperty: GIRBase
{
	OFString *_name;
	OFString *_transferOwnership;
	OFString *_version;
	OFString *_deprecatedVersion;
	GIRDoc *_doc;
	GIRDoc *_docDeprecated;
	GIRType *_type;
	bool _allowNone;
	bool _constructOnly;
	bool _readable;
	bool _deprecated;
	OFString *_construct;
	OFString *_writable;
	OFString *_setter;
	OFString *_getter;
	GIRArray *_array;
}

@property (nonatomic, copy) OFString *name;
@property (nonatomic, copy) OFString *transferOwnership;
@property (nonatomic, copy) OFString *version;
@property (nonatomic, copy) OFString *deprecatedVersion;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) GIRDoc *docDeprecated;
@property (nonatomic, retain) GIRType *type;
@property (nonatomic) bool allowNone;
@property (nonatomic) bool constructOnly;
@property (nonatomic) bool readable;
@property (nonatomic) bool deprecated;
@property (nonatomic, copy) OFString *construct;
@property (nonatomic, copy) OFString *writable;
@property (nonatomic, copy) OFString *getter;
@property (nonatomic, copy) OFString *setter;
@property (nonatomic, retain) GIRArray *array;

@end
