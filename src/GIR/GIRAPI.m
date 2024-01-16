/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIRAPI.h"
#import "GIRInclude.h"
#import "GIRNamespace.h"

@implementation GIRAPI

@synthesize version = _version, packages = _packages, include = _include, cInclude = _cInclude,
            namespaces = _namespaces;

- (instancetype)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIRAPI";
		_include = [[OFMutableArray alloc] init];
		_cInclude = [[OFMutableArray alloc] init];
		_namespaces = [[OFMutableArray alloc] init];
		_packages = [[OFMutableSet alloc] init];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[_version release];
	[_packages release];
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

			if ([value isKindOfClass:[OFMutableArray class]]) {
				OFMutableArray *myArray = (OFMutableArray *)value;
				for (OFDictionary *element in myArray) {
					[self.packages addObject:[element valueForKey:@"name"]];
				}
			} else {
				[self.packages addObject:[value valueForKey:@"name"]];
			}

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
