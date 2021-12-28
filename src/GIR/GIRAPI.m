/*
 * GIRAPI.m
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

#import "GIRAPI.h"
#import "GIRInclude.h"
#import "GIRNamespace.h"

@implementation GIRAPI

@synthesize version = _version, package = _package, include = _include,
            cInclude = _cInclude, namespaces = _namespaces;

- (instancetype)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIRAPI";
		_include = [[OFMutableArray alloc] init];
		_cInclude = [[OFMutableArray alloc] init];
		_namespaces = [[OFMutableArray alloc] init];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[_version release];
	[_package release];
	[_include release];
	[_cInclude release];
	[_namespaces release];

	[super dealloc];
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		if ([key isEqual:@"text"] || [key isEqual:@"xmlns:glib"] ||
		    [key isEqual:@"xmlns:c"] || [key isEqual:@"xmlns"]) {
			// Do nothing
		} else if ([key isEqual:@"version"]) {
			self.version = value;
		} else if ([key isEqual:@"package"]) {
			self.package = value;
		} else if ([key isEqual:@"c:include"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRInclude class]
			                      andArray:_cInclude];
		} else if ([key isEqual:@"include"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRInclude class]
			                      andArray:_include];
		} else if ([key isEqual:@"namespace"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRNamespace class]
			                      andArray:_namespaces];
		} else {
			[self logUnknownElement:key];
		}
	}
}

- (OFMutableArray *)namespaces
{
	return [[_namespaces copy] autorelease];
}

@end
