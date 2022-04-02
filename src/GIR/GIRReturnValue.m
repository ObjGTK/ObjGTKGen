/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "GIRReturnValue.h"

@implementation GIRReturnValue

@synthesize transferOwnership = _transferOwnership;
@synthesize doc = _doc;
@synthesize type = _type;
@synthesize array = _array;

- (instancetype)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIRReturnValue";
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

		// TODO: Do we need nullable?
		if ([key isEqual:@"text"] || [key isEqual:@"nullable"]) {
			// Do nothing
		} else if ([key isEqual:@"transfer-ownership"]) {
			self.transferOwnership = value;
		} else if ([key isEqual:@"doc"]) {
			self.doc = [[[GIRDoc alloc] initWithDictionary:value]
			    autorelease];
		} else if ([key isEqual:@"type"]) {
			self.type = [[[GIRType alloc] initWithDictionary:value]
			    autorelease];
		} else if ([key isEqual:@"array"]) {
			self.array = [[[GIRArray alloc]
			    initWithDictionary:value] autorelease];
		} else {
			[self logUnknownElement:key];
		}
	}
}

- (void)dealloc
{
	[_transferOwnership release];
	[_doc release];
	[_type release];
	[_array release];

	[super dealloc];
}

@end
