/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import <ObjFW/ObjFW.h>

#import "GIRBase.h"

@interface GIRAPI: GIRBase
{
	OFString *_version;
	OFMutableSet *_packages;
	OFMutableArray *_include;
	OFMutableArray *_cInclude;
	OFMutableArray *_namespaces;
}

@property (nonatomic, copy) OFString *version;
@property (nonatomic, retain) OFMutableSet *packages;
@property (nonatomic, retain) OFMutableArray *include;
@property (nonatomic, retain) OFMutableArray *cInclude;
@property (nonatomic, retain) OFMutableArray *namespaces;

@end