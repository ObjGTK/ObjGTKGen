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

/*
 * Objective-C imports
 */
#import "GIR/GIRBase.h"
#import "GIR/GIRDoc.h"
#import "GIR/GIRParameter.h"
#import "GIR/GIRReturnValue.h"

@interface GIRConstructor : GIRBase
{
	NSString *name;
	NSString *cIdentifier;
	NSString *version;
	NSString *deprecatedVersion;
	NSString *shadowedBy;
	NSString *shadows;
	BOOL introspectable;
	BOOL deprecated;
	BOOL throws;
	GIRDoc *doc;
	GIRDoc *docDeprecated;
	GIRReturnValue *returnValue;
	NSMutableArray *parameters;
	NSMutableArray *instanceParameters;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *cIdentifier;
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *deprecatedVersion;
@property (nonatomic, retain) NSString *shadowedBy;
@property (nonatomic, retain) NSString *shadows;
@property (nonatomic) BOOL introspectable;
@property (nonatomic) BOOL deprecated;
@property (nonatomic) BOOL throws;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) GIRDoc *docDeprecated;
@property (nonatomic, retain) GIRReturnValue *returnValue;
@property (nonatomic, retain) NSMutableArray *parameters;
@property (nonatomic, retain) NSMutableArray *instanceParameters;

@end
