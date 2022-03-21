/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "OGTKParameter.h"
#import "OGTKUtil.h"

/**
 * Abstracts Parameter operations
 */
@implementation OGTKParameter
@synthesize cType = _cType, cName = _cName, documentation = _documentation;

- (void)dealloc
{
	[_cType release];
	[_cName release];
	[_documentation release];

	[super dealloc];
}

- (OFString *)type
{
	return [OGTKMapper swapTypes:_cType];
}

- (OFString *)name
{
	return [OGTKUtil convertUSSToCamelCase:_cName];
}

@end
