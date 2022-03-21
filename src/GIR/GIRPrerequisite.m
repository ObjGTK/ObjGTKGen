/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "GIRPrerequisite.h"

@implementation GIRPrerequisite

@synthesize name = _name;

- (instancetype)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIRPrerequisite";
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

		if ([key isEqual:@"text"]) {
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
