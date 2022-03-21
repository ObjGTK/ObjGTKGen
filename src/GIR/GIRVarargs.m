/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "GIRVarargs.h"

@implementation GIRVarargs

- (instancetype)init
{
	self = [super init];

	_elementTypeName = @"GIRVarargs";

	return self;
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		// id value = [dict objectForKey:key];

		if ([key isEqual:@"text"] || [key isEqual:@"type"]) {
			// Do nothing
		} else {
			[self logUnknownElement:key];
		}
	}
}

@end
