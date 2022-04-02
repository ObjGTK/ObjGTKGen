/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import <ObjFW/ObjFW.h>

#import "GIRBase.h"

@interface GIRAPI: GIRBase
{
	OFString *_version;
	OFString *_package;
	OFMutableArray *_include;
	OFMutableArray *_cInclude;
	OFMutableArray *_namespaces;
}

@property (nonatomic, copy) OFString *version;
@property (nonatomic, copy) OFString *package;
@property (nonatomic, retain) OFMutableArray *include;
@property (nonatomic, retain) OFMutableArray *cInclude;
@property (nonatomic, retain) OFMutableArray *namespaces;

@end