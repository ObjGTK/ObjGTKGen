/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIRType.h"

@implementation GIRType

@synthesize cType = _cType;
@synthesize name = _name;

- (instancetype)init
{
	self = [super init];

	_elementTypeName = @"GIRType";

	return self;
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		if ([key isEqual:@"text"] || [key isEqual:@"type"]) {
			// Do nothing
		} else if ([key isEqual:@"c:type"]) {
			// Fix if GIR file provides internal type names starting with _
			if([value characterAtIndex:0] == '_')
				value = [value substringFromIndex:1];

			self.cType = value;
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else {
			[self logUnknownElement:key];
		}
	}
}

- (void)dealloc
{
	[_cType release];
	[_name release];

	[super dealloc];
}

@end
