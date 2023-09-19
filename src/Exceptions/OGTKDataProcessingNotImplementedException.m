/*
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2021-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "OGTKDataProcessingNotImplementedException.h"

@implementation OGTKDataProcessingNotImplementedException

@synthesize description = _description;

+ (instancetype)exception
{
	OF_UNRECOGNIZED_SELECTOR
}

- (instancetype)init
{
	OF_INVALID_INIT_METHOD
}

+ (instancetype)exceptionWithDescription:(OFString *)description;
{
	return [[[self alloc] initWithDescription:description] autorelease];
}

- (instancetype)initWithDescription:(OFString *)description
{
	self = [super init];

	@try {
		_description = [description copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[_description release];

	[super dealloc];
}

@end