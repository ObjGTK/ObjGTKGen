/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "GIRInclude.h"

@implementation GIRInclude

@synthesize name = _name, version = _version;

- (id)init
{
	self = [super init];

	_elementTypeName = @"GIRInclude";

	return self;
}

- (void)dealloc
{
	[_name release];
	[_version release];

	[super dealloc];
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		if ([key isEqual:@"text"] || [key isEqual:@"type"]) {
			// Do nothing
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else if ([key isEqual:@"version"]) {
			self.version = value;
		} else {
			[self logUnknownElement:key];
		}
	}
}

@end
