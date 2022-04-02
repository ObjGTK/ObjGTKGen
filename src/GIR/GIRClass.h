/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import <ObjFW/ObjFW.h>

#import "GIRBase.h"
#import "GIRConstructor.h"
#import "GIRDoc.h"
#import "GIRField.h"
#import "GIRFunction.h"
#import "GIRImplements.h"
#import "GIRMethod.h"
#import "GIRProperty.h"
#import "GIRVirtualMethod.h"

@interface GIRClass: GIRBase
{
	OFString *_name;
	OFString *_cType;
	OFString *_cSymbolPrefix;
	OFString *_parent;
	OFString *_version;
	bool _abstract;
	GIRDoc *_doc;
	OFMutableArray *_constructors;
	OFMutableArray *_fields;
	OFMutableArray *_methods;
	OFMutableArray *_virtualMethods;
	OFMutableArray *_properties;
	OFMutableArray *_implements;
	OFMutableArray *_functions;
}

@property (nonatomic, copy) OFString *name;
@property (nonatomic, copy) OFString *cType;
@property (nonatomic, copy) OFString *cSymbolPrefix;
@property (nonatomic, copy) OFString *parent;
@property (nonatomic, copy) OFString *version;
@property (nonatomic) bool abstract;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) OFMutableArray *constructors;
@property (nonatomic, retain) OFMutableArray *fields;
@property (nonatomic, retain) OFMutableArray *methods;
@property (nonatomic, retain) OFMutableArray *virtualMethods;
@property (nonatomic, retain) OFMutableArray *properties;
@property (nonatomic, retain) OFMutableArray *implements;
@property (nonatomic, retain) OFMutableArray *functions;

@end
