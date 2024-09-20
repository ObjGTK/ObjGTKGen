/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIREnumeration.h"

@implementation GIREnumeration

@synthesize cType = _cType;
@synthesize name = _name;
@synthesize version = _version;
@synthesize deprecatedVersion = _deprecatedVersion;
@synthesize deprecated = _deprecated;
@synthesize doc = _doc;
@synthesize docDeprecated = _docDeprecated;
@synthesize members = _members;
@synthesize functions = _functions;

- (instancetype)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIREnumeration";
		_members = [[OFMutableArray alloc] init];
		_functions = [[OFMutableArray alloc] init];
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

		if ([key isEqual:@"text"] || [key isEqual:@"source-position"] ||
		    [key isEqual:@"glib:type-name"] || [key isEqual:@"glib:get-type"] ||
		    [key isEqual:@"glib:error-domain"]) {
			// Do nothing
		} else if ([key isEqual:@"c:type"]) {
			self.cType = value;
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else if ([key isEqual:@"version"]) {
			self.version = value;
		} else if ([key isEqual:@"deprecated-version"]) {
			self.deprecatedVersion = value;
		} else if ([key isEqual:@"deprecated"]) {
			self.deprecated = [value isEqual:@"1"];
		} else if ([key isEqual:@"doc"]) {
			self.doc = [[[GIRDoc alloc] initWithDictionary:value] autorelease];
		} else if ([key isEqual:@"doc-deprecated"]) {
			self.docDeprecated =
			    [[[GIRDoc alloc] initWithDictionary:value] autorelease];
		} else if ([key isEqual:@"member"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRMember class]
			                      andArray:_members];
		} else if ([key isEqual:@"function"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRFunction class]
			                      andArray:_functions];
		} else {
			[self logUnknownElement:key];
		}
	}
}

- (void)addMemberDictionary:(id)object
{
	[GIRBase log:@"Adding member" andLevel:Debug];

	// Create the array if this is the first time through
	if (_members == nil) {
		_members = [[OFMutableArray alloc] init];
	}

	if ([object isKindOfClass:[OFDictionary class]]) {
		[_members addObject:[[[GIRMember alloc] initWithDictionary:object] autorelease]];
	}
}

- (void)addFunctionDictionary:(id)object
{
	[GIRBase log:@"Adding function" andLevel:Debug];

	// Create the array if this is the first time through
	if (_functions == nil) {
		_functions = [[OFMutableArray alloc] init];
	}

	if ([object isKindOfClass:[OFDictionary class]]) {
		[_functions
		    addObject:[[[GIRFunction alloc] initWithDictionary:object] autorelease]];
	}
}

- (void)dealloc
{
	[_cType release];
	[_name release];
	[_version release];
	[_deprecatedVersion release];
	[_doc release];
	[_docDeprecated release];
	[_members release];
	[_functions release];

	[super dealloc];
}

@end
