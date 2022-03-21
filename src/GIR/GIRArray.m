/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "GIRArray.h"

@implementation GIRArray

@synthesize cType = _cType;
@synthesize name = _name;
@synthesize length = _length;
@synthesize fixedSize = _fixedSize;
@synthesize zeroTerminated = _zeroTerminated;
@synthesize type = _type;

- (instancetype)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIRArray";
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

		if ([key isEqual:@"text"]) {
			// Do nothing
		} else if ([key isEqual:@"c:type"]) {
			self.cType = value;
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else if ([key isEqual:@"length"]) {
			self.length = [value longLongValue];
		} else if ([key isEqual:@"fixed-size"]) {
			self.fixedSize = [value longLongValue];
		} else if ([key isEqual:@"zero-terminated"]) {
			self.zeroTerminated = [value isEqual:@"1"];
		} else if ([key isEqual:@"type"]) {
			self.type = [[[GIRType alloc] initWithDictionary:value]
			    autorelease];
		} else {
			[self logUnknownElement:key];
		}
	}
}

- (void)dealloc
{
	[_cType release];
	[_name release];
	[_type release];

	[super dealloc];
}

@end
