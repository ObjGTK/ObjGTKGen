/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
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
