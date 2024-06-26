/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIRMember.h"

@implementation GIRMember

@synthesize cIdentifier = _cIdentifier;
@synthesize name = _name;
@synthesize theValue = _theValue;
@synthesize doc = _doc;

- (instancetype)init
{
	self = [super init];

	_elementTypeName = @"GIRMember";

	return self;
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		if ([key isEqual:@"text"] || [key isEqual:@"glib:nick"] ||
		    [key isEqual:@"glib:name"] || [key isEqual:@"version"] ||
		    [key isEqual:@"doc-deprecated"]) {
			// Do nothing
		} else if ([key isEqual:@"c:identifier"]) {
			self.cIdentifier = value;
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else if ([key isEqual:@"value"]) {
			self.theValue = [value longLongValue];
		} else if ([key isEqual:@"doc"]) {
			self.doc = [[[GIRDoc alloc] initWithDictionary:value] autorelease];
		} else {
			[self logUnknownElement:key];
		}
	}
}

- (void)dealloc
{
	[_cIdentifier release];
	[_name release];
	[_doc release];

	[super dealloc];
}

@end
