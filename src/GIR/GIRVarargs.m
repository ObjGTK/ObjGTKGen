/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
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
