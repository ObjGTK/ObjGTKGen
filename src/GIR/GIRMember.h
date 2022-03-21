/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
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
