/*
 * GIRClass.m
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

#import "GIRClass.h"

@implementation GIRClass

@synthesize name = _name;
@synthesize cType = _cType;
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

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		// TODO: Do we need signal?
		if ([key isEqual:@"text"] || [key isEqual:@"glib:type-name"] ||
		    [key isEqual:@"glib:type-struct"] ||
		    [key isEqual:@"glib:get-type"] ||
		    [key isEqual:@"glib:signal"] ||
		    [key isEqual:@"source-position"] ||
		    [key isEqual:@"signal"]) {
			// Do nothing
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else if ([key isEqual:@"c:type"]) {
			self.cType = value;
		} else if ([key isEqual:@"c:symbol-prefix"]) {
			self.cSymbolPrefix = value;
		} else if ([key isEqual:@"parent"]) {
			self.parent = value;
		} else if ([key isEqual:@"version"]) {
			self.version = value;
		} else if ([key isEqual:@"abstract"]) {
			self.abstract = [value isEqual:@"1"];
		} else if ([key isEqual:@"doc"]) {
			self.doc = [[[GIRDoc alloc] initWithDictionary:value]
			    autorelease];
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

- (void)dealloc
{
	[_name release];
	[_cType release];
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

@end
