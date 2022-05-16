/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
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
