/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "GIRParameter.h"

@implementation GIRParameter

@synthesize name = _name;
@synthesize transferOwnership = _transferOwnership;
@synthesize direction = _direction;
@synthesize scope = _scope;
@synthesize allowNone = _allowNone;
@synthesize callerAllocates = _callerAllocates;
@synthesize closure = _closure;
@synthesize destroy = _destroy;
@synthesize doc = _doc;
@synthesize type = _type;
@synthesize array = _array;
@synthesize varargs = _varargs;

- (instancetype)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIRParameter";
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

		// TODO: Check if we need nullable or optional
		if ([key isEqual:@"text"] || [key isEqual:@"nullable"] ||
		    [key isEqual:@"optional"]) {
			// Do nothing
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else if ([key isEqual:@"transfer-ownership"]) {
			self.transferOwnership = value;
		} else if ([key isEqual:@"direction"]) {
			self.direction = value;
		} else if ([key isEqual:@"scope"]) {
			self.scope = value;
		} else if ([key isEqual:@"allow-none"]) {
			self.allowNone = [value isEqual:@"1"];
		} else if ([key isEqual:@"caller-allocates"]) {
			self.callerAllocates = [value isEqual:@"1"];
		} else if ([key isEqual:@"closure"]) {
			self.closure = [value longLongValue];
		} else if ([key isEqual:@"destroy"]) {
			self.destroy = [value longLongValue];
		} else if ([key isEqual:@"doc"]) {
			self.doc = [[[GIRDoc alloc] initWithDictionary:value]
			    autorelease];
		} else if ([key isEqual:@"type"]) {
			self.type = [[[GIRType alloc] initWithDictionary:value]
			    autorelease];
		} else if ([key isEqual:@"array"]) {
			self.array = [[[GIRArray alloc]
			    initWithDictionary:value] autorelease];
		} else if ([key isEqual:@"varargs"]) {
			self.varargs = [[[GIRVarargs alloc]
			    initWithDictionary:value] autorelease];
		} else {
			[self logUnknownElement:key];
		}
	}
}

- (void)dealloc
{
	[_name release];
	[_transferOwnership release];
	[_direction release];
	[_scope release];
	[_doc release];
	[_type release];
	[_array release];
	[_varargs release];

	[super dealloc];
}

@end
