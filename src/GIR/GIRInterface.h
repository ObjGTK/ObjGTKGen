/*
 * GIRInterface.h
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
#import "GIRField.h"
#import "GIRMethod.h"
#import "GIRPrerequisite.h"
#import "GIRProperty.h"
#import "GIRVirtualMethod.h"

@interface GIRInterface: GIRBase
{
	OFString *_name;
	OFString *_cType;
	OFString *_cSymbolPrefix;
	GIRDoc *_doc;
	OFMutableArray *_fields;
	OFMutableArray *_methods;
	OFMutableArray *_virtualMethods;
	OFMutableArray *_properties;
	GIRPrerequisite *_prerequisite;
}

@property (nonatomic, retain) OFString *name;
@property (nonatomic, retain) OFString *cType;
@property (nonatomic, retain) OFString *cSymbolPrefix;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) OFMutableArray *fields;
@property (nonatomic, retain) OFMutableArray *methods;
@property (nonatomic, retain) OFMutableArray *virtualMethods;
@property (nonatomic, retain) OFMutableArray *properties;
@property (nonatomic, retain) GIRPrerequisite *prerequisite;

@end
