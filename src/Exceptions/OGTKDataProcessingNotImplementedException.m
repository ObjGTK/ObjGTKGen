/*
 * Copyright 2021 Johannes Brakensiek <letterus at codingpastor.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "OGTKDataProcessingNotImplementedException.h"

@implementation OGTKDataProcessingNotImplementedException

@synthesize description = _description;

+ (instancetype)exception
{
	OF_UNRECOGNIZED_SELECTOR
}

+ (instancetype)exceptionWithDescription:(OFString *)description;
{
	return [[[self alloc] initWithDescription:description] autorelease];
}

- (instancetype)initWithDescription:(OFString *)description
{
	self = [super init];

	@try {
		_description = [_description copy];
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