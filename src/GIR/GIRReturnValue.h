/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import <ObjFW/ObjFW.h>

#import "GIRArray.h"
#import "GIRBase.h"
#import "GIRDoc.h"
#import "GIRType.h"

@interface GIRReturnValue: GIRBase
{
	OFString *_transferOwnership;
	GIRDoc *_doc;
	GIRType *_type;
	GIRArray *_array;
}

@property (nonatomic, retain) OFString *transferOwnership;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) GIRType *type;
@property (nonatomic, retain) GIRArray *array;

@end
