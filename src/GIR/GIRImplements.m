/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIRImplements.h"

@implementation GIRImplements

@synthesize name = _name;

- (id)init
{
	self = [super init];

	_elementTypeName = @"GIRImplements";

	return self;
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		if ([key isEqual:@"text"] || [key isEqual:@"type"]) {
			// Do nothing
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else {
			[self logUnknownElement:key];
		}
	}
}

- (void)dealloc
{
	[_name release];

	[super dealloc];
}

@end
