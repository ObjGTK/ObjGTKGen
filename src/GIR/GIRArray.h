/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import <ObjFW/ObjFW.h>

#import "GIRBase.h"
#import "GIRType.h"

@interface GIRArray: GIRBase
{
	OFString *_cType;
	OFString *_name;
	int _length;
	int _fixedSize;
	bool _zeroTerminated;
	GIRType *_type;
}

@property (nonatomic, retain) OFString *cType;
@property (nonatomic, retain) OFString *name;
@property (nonatomic) int length;
@property (nonatomic) int fixedSize;
@property (nonatomic) bool zeroTerminated;
@property (nonatomic, retain) GIRType *type;

@end
