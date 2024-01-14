/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2024 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2024 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIRReturnValue.h"

OFString *const kOwnershipTransferTypeNone = @"none";
OFString *const kOwnershipTransferTypeContainer = @"container";
OFString *const kOwnershipTransferTypeFull = @"full";
// Alias for none
OFString *const kOwnershipTransferTypeFloating = @"floating";

@implementation GIRReturnValue

@synthesize transferOwnership = _transferOwnership;
@synthesize doc = _doc;
@synthesize type = _type;
@synthesize array = _array;

- (instancetype)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIRReturnValue";
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[_doc release];
	[_type release];
	[_array release];

	[super dealloc];
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		// TODO: Do we need to translate nullable into ObjC?
		if ([key isEqual:@"text"] || [key isEqual:@"nullable"] ||
		    [key isEqual:@"attribute"]) {
			// Do nothing
		} else if ([key isEqual:@"transfer-ownership"]) {
			if ([value isEqual:kOwnershipTransferTypeNone] ||
			    [value isEqual:kOwnershipTransferTypeFloating]) {
				self.transferOwnership = GIRReturnValueOwnershipNone;
			} else if ([value isEqual:kOwnershipTransferTypeContainer]) {
				self.transferOwnership = GIRReturnValueOwnershipContainer;
			} else if ([value isEqual:kOwnershipTransferTypeFull]) {
				self.transferOwnership = GIRReturnValueOwnershipFull;
			} else {
				[self
				    logUnknownElement:
				        [OFString stringWithFormat:@"Unknown value %@ for key %@.",
				                  value, key]];
			}
		} else if ([key isEqual:@"doc"]) {
			self.doc = [[[GIRDoc alloc] initWithDictionary:value] autorelease];
		} else if ([key isEqual:@"type"]) {
			self.type = [[[GIRType alloc] initWithDictionary:value] autorelease];
		} else if ([key isEqual:@"array"]) {
			self.array = [[[GIRArray alloc] initWithDictionary:value] autorelease];
		} else {
			[self logUnknownElement:key];
		}
	}
}

@end
