/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "GIRInterface.h"

@implementation GIRInterface

@synthesize name = _name;
@synthesize cType = _cType;
@synthesize cSymbolPrefix = _cSymbolPrefix;
@synthesize doc = _doc;
@synthesize fields = _fields;
@synthesize methods = _methods;
@synthesize virtualMethods = _virtualMethods;
@synthesize properties = _properties;
@synthesize prerequisite = _prerequisite;

- (instancetype)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIRInterface";
		_fields = [[OFMutableArray alloc] init];
		_methods = [[OFMutableArray alloc] init];
		_virtualMethods = [[OFMutableArray alloc] init];
		_properties = [[OFMutableArray alloc] init];
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

		if ([key isEqual:@"text"] || [key isEqual:@"glib:type-name"] ||
		    [key isEqual:@"glib:type-struct"] ||
		    [key isEqual:@"glib:signal"] ||
		    [key isEqual:@"glib:get-type"] ||
		    [key isEqual:@"source-position"] ||
		    [key isEqual:@"version"] || [key isEqual:@"signal"]) {
			// Do nothing
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else if ([key isEqual:@"c:type"]) {
			self.cType = value;
		} else if ([key isEqual:@"c:symbol-prefix"]) {
			self.cSymbolPrefix = value;
		} else if ([key isEqual:@"doc"]) {
			self.doc = [[[GIRDoc alloc] initWithDictionary:value]
			    autorelease];
		} else if ([key isEqual:@"fields"]) {
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
		} else if ([key isEqual:@"prerequisite"]) {
			self.prerequisite = [[[GIRPrerequisite alloc]
			    initWithDictionary:value] autorelease];
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
	[_doc release];
	[_fields release];
	[_methods release];
	[_virtualMethods release];
	[_properties release];
	[_prerequisite release];

	[super dealloc];
}

@end
