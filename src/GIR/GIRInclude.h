/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

#import "GIRBase.h"

@interface GIRInclude: GIRBase
{
	OFString *_name;
    OFString *_version;
}

@property (nonatomic, copy) OFString *name;
@property (nonatomic, copy) OFString *version;

@end
