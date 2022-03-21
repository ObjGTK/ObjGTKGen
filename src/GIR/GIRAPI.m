/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
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
			self.package = [value valueForKey:@"name"];
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
