/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

#import "OGTKMapper.h"

/**
 * Abstracts Parameter operations
 */
@interface OGTKParameter: OFObject
{
	OFString *_cType;
	OFString *_cName;
	OFString *_documentation;
}

@property (copy, nonatomic) OFString *cType;
@property (readonly, nonatomic) OFString *type;
@property (copy, nonatomic) OFString *cName;
@property (readonly, nonatomic) OFString *name;
@property (copy, nonatomic) OFString *documentation;

@end
