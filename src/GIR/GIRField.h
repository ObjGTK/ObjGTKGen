/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import <ObjFW/ObjFW.h>

#import "GIRArray.h"
#import "GIRBase.h"
#import "GIRType.h"

@interface GIRField: GIRBase
{
	OFString *_name;
	bool _isPrivate;
	bool _readable;
	int _bits;
	GIRType *_type;
	GIRArray *_array;
}

@property (nonatomic, retain) OFString *name;
@property (nonatomic) bool isPrivate;
@property (nonatomic) bool readable;
@property (nonatomic) int bits;
@property (nonatomic, retain) GIRType *type;
@property (nonatomic, retain) GIRArray *array;

@end
