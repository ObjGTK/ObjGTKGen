/*
 * GIRConstructor.h
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

#import "GIRBase.h"
#import "GIRDoc.h"
#import "GIRParameter.h"
#import "GIRReturnValue.h"

@interface GIRConstructor: GIRBase
{
	OFString *_name;
	OFString *_cIdentifier;
	OFString *_version;
	OFString *_deprecatedVersion;
	OFString *_shadowedBy;
	OFString *_shadows;
	bool _introspectable;
	bool _deprecated;
	bool _throws;
	GIRDoc *_doc;
	GIRDoc *_docDeprecated;
	GIRReturnValue *_returnValue;
	OFMutableArray *_parameters;
	OFMutableArray *_instanceParameters;
}

@property (nonatomic, retain) OFString *name;
@property (nonatomic, retain) OFString *cIdentifier;
@property (nonatomic, retain) OFString *version;
@property (nonatomic, retain) OFString *deprecatedVersion;
@property (nonatomic, retain) OFString *shadowedBy;
@property (nonatomic, retain) OFString *shadows;
@property (nonatomic) bool introspectable;
@property (nonatomic) bool deprecated;
@property (nonatomic) bool throws;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) GIRDoc *docDeprecated;
@property (nonatomic, retain) GIRReturnValue *returnValue;
@property (nonatomic, retain) OFMutableArray *parameters;
@property (nonatomic, retain) OFMutableArray *instanceParameters;

@end
