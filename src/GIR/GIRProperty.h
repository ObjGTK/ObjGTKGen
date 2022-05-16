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
