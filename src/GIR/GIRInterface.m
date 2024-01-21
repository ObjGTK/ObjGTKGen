/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIRInterface.h"

@implementation GIRInterface

@synthesize name = _name;
@synthesize cType = _cType;
@synthesize cSymbolPrefix = _cSymbolPrefix;
@synthesize doc = _doc;
@synthesize fields = _fields;
@synthesize functions = _functions;
@synthesize methods = _methods;
@synthesize virtualMethods = _virtualMethods;
@synthesize properties = _properties;
@synthesize prerequisites = _prerequisites;

- (instancetype)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIRInterface";
		_fields = [[OFMutableArray alloc] init];
		_functions = [[OFMutableArray alloc] init];
		_methods = [[OFMutableArray alloc] init];
		_virtualMethods = [[OFMutableArray alloc] init];
		_properties = [[OFMutableArray alloc] init];
		_prerequisites = [[OFMutableArray alloc] init];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[_name release];
	[_cType release];
	[_cSymbolPrefix release];
	[_doc release];
	[_fields release];
	[_methods release];
	[_virtualMethods release];
	[_properties release];
	[_prerequisites release];

	[super dealloc];
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		// If this class was needed we would need to implement "deprecated"
		if ([key isEqual:@"text"] || [key isEqual:@"glib:type-name"] ||
		    [key isEqual:@"glib:type-struct"] || [key isEqual:@"glib:signal"] ||
		    [key isEqual:@"glib:get-type"] || [key isEqual:@"source-position"] ||
		    [key isEqual:@"version"] || [key isEqual:@"signal"] ||
		    [key isEqual:@"deprecated-version"] || [key isEqual:@"doc-deprecated"] ||
		    [key isEqual:@"deprecated"]) {
			// Do nothing
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else if ([key isEqual:@"c:type"]) {
			self.cType = value;
		} else if ([key isEqual:@"c:symbol-prefix"]) {
			self.cSymbolPrefix = value;
		} else if ([key isEqual:@"doc"]) {
			self.doc = [[[GIRDoc alloc] initWithDictionary:value] autorelease];
		} else if ([key isEqual:@"fields"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRField class]
			                      andArray:_fields];
		} else if ([key isEqual:@"method"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRMethod class]
			                      andArray:_methods];
		} else if ([key isEqual:@"function"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRMethod class]
			                      andArray:_functions];
		} else if ([key isEqual:@"virtual-method"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRVirtualMethod class]
			                      andArray:_virtualMethods];
		} else if ([key isEqual:@"property"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRProperty class]
			                      andArray:_properties];
		} else if ([key isEqual:@"prerequisite"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRPrerequisite class]
			                      andArray:_prerequisites];
		} else {
			[self logUnknownElement:key];
		}
	}
}

@end
