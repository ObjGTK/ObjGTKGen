/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIRArray.h"

@implementation GIRArray

@synthesize cType = _cType;
@synthesize name = _name;
@synthesize length = _length;
@synthesize fixedSize = _fixedSize;
@synthesize zeroTerminated = _zeroTerminated;
@synthesize type = _type;

- (instancetype)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIRArray";
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		if ([key isEqual:@"text"] || [key isEqual:@"array"]) {
			// Do nothing
		} else if ([key isEqual:@"c:type"]) {
			self.cType = value;
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else if ([key isEqual:@"length"]) {
			self.length = [value longLongValue];
		} else if ([key isEqual:@"fixed-size"]) {
			self.fixedSize = [value longLongValue];
		} else if ([key isEqual:@"zero-terminated"]) {
			self.zeroTerminated = [value isEqual:@"1"];
		} else if ([key isEqual:@"type"]) {
			self.type = [[[GIRType alloc] initWithDictionary:value] autorelease];
		} else {
			[self logUnknownElement:key];
		}
	}
}

- (void)dealloc
{
	[_cType release];
	[_name release];
	[_type release];

	[super dealloc];
}

@end
