/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIRDoc.h"

@implementation GIRDoc

@synthesize xmlSpace = _xmlSpace;
@synthesize xmlWhitespace = _xmlWhitespace;
@synthesize docText = _docText;

- (instancetype)init
{
	self = [super init];

	_elementTypeName = @"GIRDoc";

	return self;
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		if ([key isEqual:@"filename"] || [key isEqual:@"line"]) {
			// do nothing - suppress warning
		} else if ([key isEqual:@"text"]) {
			self.docText = value;
		} else if ([key isEqual:@"xml:space"]) {
			self.xmlSpace = value;
		} else if ([key isEqual:@"xml:whitespace"]) {
			self.xmlWhitespace = value;
		} else {
			[self logUnknownElement:key];
		}
	}
}

- (void)dealloc
{
	[_xmlSpace release];
	[_xmlWhitespace release];
	[_docText release];

	[super dealloc];
}

@end
