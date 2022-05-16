/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import <ObjFW/ObjFW.h>

#import "GIRBase.h"

@interface GIRDoc: GIRBase
{
	OFString *_xmlSpace;
	OFString *_xmlWhitespace;
	OFString *_docText;
}

@property (nonatomic, retain) OFString *xmlSpace;
@property (nonatomic, retain) OFString *xmlWhitespace;
@property (nonatomic, retain) OFString *docText;

@end
