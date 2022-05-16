/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIRProperty.h"

@implementation GIRProperty

@synthesize name = _name;
@synthesize transferOwnership = _transferOwnership;
@synthesize version = _version;
@synthesize deprecatedVersion = _deprecatedVersion;
@synthesize doc = _doc;
@synthesize docDeprecated = _docDeprecated;
@synthesize type = _type;
@synthesize allowNone = _allowNone;
@synthesize constructOnly = _constructOnly;
@synthesize readable = _readable;
@synthesize deprecated = _deprecated;
@synthesize construct = _construct;
@synthesize writable = _writable;
@synthesize getter = _getter;
@synthesize setter = _setter;
@synthesize array = _array;

- (instancetype)init
{
	self = [super init];

	_elementTypeName = @"GIRProperty";

	return self;
}

- (void)dealloc
{
	[_name release];
	[_transferOwnership release];
	[_version release];
	[_deprecatedVersion release];
	[_doc release];
	[_docDeprecated release];
	[_type release];
	[_construct release];
	[_writable release];
	[_getter release];
	[_setter release];
	[_array release];

	[super dealloc];
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		if ([key isEqual:@"text"]) {
			// Do nothing
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else if ([key isEqual:@"transfer-ownership"]) {
			self.transferOwnership = value;
		} else if ([key isEqual:@"version"]) {
			self.version = value;
		} else if ([key isEqual:@"deprecated-version"]) {
			self.deprecatedVersion = value;
		} else if ([key isEqual:@"doc"]) {
			self.doc = [[[GIRDoc alloc] initWithDictionary:value]
			    autorelease];
		} else if ([key isEqual:@"doc-deprecated"]) {
			self.docDeprecated = [[[GIRDoc alloc]
			    initWithDictionary:value] autorelease];
		} else if ([key isEqual:@"type"]) {
			self.type = [[[GIRType alloc] initWithDictionary:value]
			    autorelease];
		} else if ([key isEqual:@"allow-none"]) {
			self.allowNone = [value isEqual:@"1"];
		} else if ([key isEqual:@"construct-only"]) {
			self.constructOnly = [value isEqual:@"1"];
		} else if ([key isEqual:@"readable"]) {
			self.readable = [value isEqual:@"1"];
		} else if ([key isEqual:@"deprecated"]) {
			self.deprecated = [value isEqual:@"1"];
		} else if ([key isEqual:@"construct"]) {
			self.construct = value;
		} else if ([key isEqual:@"writable"]) {
			self.writable = value;
		} else if ([key isEqual:@"getter"]) {
			self.getter = value;
		} else if ([key isEqual:@"setter"]) {
			self.setter = value;
		} else if ([key isEqual:@"array"]) {
			self.array = [[[GIRArray alloc]
			    initWithDictionary:value] autorelease];
		} else {
			[self logUnknownElement:key];
		}
	}
}

@end
