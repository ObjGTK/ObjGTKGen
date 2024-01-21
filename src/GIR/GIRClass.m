/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIRClass.h"

@implementation GIRClass

@synthesize name = _name;
@synthesize cType = _cType;
@synthesize glibTypeName = _glibTypeName;
@synthesize cSymbolPrefix = _cSymbolPrefix;
@synthesize parent = _parent;
@synthesize version = _version;
@synthesize abstract = _abstract;
@synthesize doc = _doc;
@synthesize constructors = _constructors;
@synthesize fields = _fields;
@synthesize methods = _methods;
@synthesize virtualMethods = _virtualMethods;
@synthesize properties = _properties;
@synthesize implements = _implements;
@synthesize functions = _functions;

- (instancetype)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIRClass";
		_constructors = [[OFMutableArray alloc] init];
		_fields = [[OFMutableArray alloc] init];
		_methods = [[OFMutableArray alloc] init];
		_virtualMethods = [[OFMutableArray alloc] init];
		_properties = [[OFMutableArray alloc] init];
		_implements = [[OFMutableArray alloc] init];
		_functions = [[OFMutableArray alloc] init];
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
	[_glibTypeName release];
	[_cSymbolPrefix release];
	[_parent release];
	[_version release];
	[_doc release];
	[_constructors release];
	[_fields release];
	[_methods release];
	[_virtualMethods release];
	[_properties release];
	[_implements release];
	[_functions release];

	[super dealloc];
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		// TODO: We need to implement "deprecated" otherwise many classes will be generated
		// unnecessarily
		if ([key isEqual:@"text"] || [key isEqual:@"glib:type-struct"] ||
		    [key isEqual:@"glib:get-type"] || [key isEqual:@"glib:signal"] ||
		    [key isEqual:@"glib:fundamental"] || [key isEqual:@"source-position"] ||
		    [key isEqual:@"signal"] || [key isEqual:@"deprecated-version"] ||
		    [key isEqual:@"doc-deprecated"] ||
		    // The following are used for class "Expression" only it seems
		    [key isEqual:@"glib:ref-func"] || [key isEqual:@"glib:unref-func"] ||
		    [key isEqual:@"glib:get-value-func"] || [key isEqual:@"glib:set-value-func"]) {
			// Do nothing
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else if ([key isEqual:@"c:type"]) {
			self.cType = value;
		} else if ([key isEqual:@"c:symbol-prefix"]) {
			self.cSymbolPrefix = value;
		} else if ([key isEqual:@"glib:type-name"]) {
			self.glibTypeName = value;
		} else if ([key isEqual:@"parent"]) {
			self.parent = value;
		} else if ([key isEqual:@"version"]) {
			self.version = value;
		} else if ([key isEqual:@"abstract"]) {
			self.abstract = [value isEqual:@"1"];
		} else if ([key isEqual:@"doc"]) {
			self.doc = [[[GIRDoc alloc] initWithDictionary:value] autorelease];
		} else if ([key isEqual:@"constructor"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRConstructor class]
			                      andArray:_constructors];
		} else if ([key isEqual:@"field"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRField class]
			                      andArray:_fields];
		} else if ([key isEqual:@"method"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRMethod class]
			                      andArray:_methods];
		} else if ([key isEqual:@"virtual-method"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRVirtualMethod class]
			                      andArray:_virtualMethods];
		} else if ([key isEqual:@"property"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRProperty class]
			                      andArray:_properties];
		} else if ([key isEqual:@"implements"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRImplements class]
			                      andArray:_implements];
		} else if ([key isEqual:@"function"]) {
			[self processArrayOrDictionary:value
			                     withClass:[GIRFunction class]
			                      andArray:_functions];
		} else {
			[self logUnknownElement:key];
		}
	}
}

@end
