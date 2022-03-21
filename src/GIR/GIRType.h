/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

#import "GIRBase.h"

@interface GIRType: GIRBase
{
	OFString *_cType;
	OFString *_name;
}

@property (nonatomic, retain) OFString *cType;
@property (nonatomic, retain) OFString *name;

@end
