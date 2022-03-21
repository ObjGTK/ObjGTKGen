/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "GIRVirtualMethod.h"

@implementation GIRVirtualMethod

- (instancetype)init
{
	self = [super init];

	_elementTypeName = @"GIRVirtualMethod";

	return self;
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		if ([super tryParseWithKey:key andValue:value]) {
			// Parsed OK by GIRMethod
		} else {
			[self logUnknownElement:key];
		}
	}
}

@end
