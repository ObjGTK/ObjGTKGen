/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIRConstant.h"

@implementation GIRConstant

@synthesize cType = _cType;
@synthesize name = _name;
@synthesize theValue = _theValue;
@synthesize version = _version;
@synthesize deprecatedVersion = _deprecatedVersion;
@synthesize deprecated = _deprecated;
@synthesize doc = _doc;
@synthesize docDeprecated = _docDeprecated;
@synthesize type = _type;

- (instancetype)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIRConstant";
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

		if ([key isEqual:@"text"] || [key isEqual:@"type"] ||
		    [key isEqual:@"source-position"]) {
			// Do nothing
		} else if ([key isEqual:@"c:type"]) {
			self.cType = value;
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else if ([key isEqual:@"value"]) {
			self.theValue = value;
		} else if ([key isEqual:@"version"]) {
			self.version = value;
		} else if ([key isEqual:@"deprecated-version"]) {
			self.deprecatedVersion = value;
		} else if ([key isEqual:@"deprecated"]) {
			self.deprecated = [value isEqual:@"1"];
		} else if ([key isEqual:@"doc"]) {
			self.doc = [[[GIRDoc alloc] initWithDictionary:value]
			    autorelease];
		} else if ([key isEqual:@"doc-deprecated"]) {
			self.docDeprecated = [[[GIRDoc alloc]
			    initWithDictionary:value] autorelease];
		} else if ([key isEqual:@"type"]) {
			self.type = [[[GIRType alloc] initWithDictionary:value]
			    autorelease];
		} else {
			[self logUnknownElement:key];
		}
	}
}

- (void)dealloc
{
	[_cType release];
	[_name release];
	[_theValue release];
	[_version release];
	[_deprecatedVersion release];
	[_doc release];
	[_docDeprecated release];
	[_type release];

	[super dealloc];
}

@end
