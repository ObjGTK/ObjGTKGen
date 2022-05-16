/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIRBase.h"
#import "GIRDoc.h"

@interface GIRMember: GIRBase
{
	OFString *_cIdentifier;
	OFString *_name;
	long _theValue;
	GIRDoc *_doc;
}

@property (nonatomic, retain) OFString *cIdentifier;
@property (nonatomic, retain) OFString *name;
@property (nonatomic) long theValue;
@property (nonatomic, retain) GIRDoc *doc;

@end
