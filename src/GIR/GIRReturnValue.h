/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2024 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2024 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import <ObjFW/ObjFW.h>

#import "GIRArray.h"
#import "GIRBase.h"
#import "GIRDoc.h"
#import "GIRType.h"

typedef enum {
	GIRReturnValueOwnershipNone,
	GIRReturnValueOwnershipContainer,
	GIRReturnValueOwnershipFull
} GIROwnershipTransferType;

@interface GIRReturnValue: GIRBase
{
	GIROwnershipTransferType _transferOwnership;
	GIRDoc *_doc;
	GIRType *_type;
	GIRArray *_array;
}

@property (atomic) GIROwnershipTransferType transferOwnership;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) GIRType *type;
@property (nonatomic, retain) GIRArray *array;

@end
