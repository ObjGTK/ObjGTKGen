/*
 * GIREnumeration.m
 * This file is part of ObjGTK
 *
 * Copyright (C) 2017 - Tyler Burton
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
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
		    [key isEqual:@"glib:type-name"] ||
		    [key isEqual:@"glib:get-type"] ||
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
			self.doc = [[[GIRDoc alloc] initWithDictionary:value]
			    autorelease];
		} else if ([key isEqual:@"doc-deprecated"]) {
			self.docDeprecated = [[[GIRDoc alloc]
			    initWithDictionary:value] autorelease];
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
		[_members
		    addObject:[[[GIRMember alloc] initWithDictionary:object]
		                  autorelease]];
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
		    addObject:[[[GIRFunction alloc] initWithDictionary:object]
		                  autorelease]];
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
