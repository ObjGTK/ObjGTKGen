/*
 * SPDX-FileCopyrightText: 2021-2023 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2021-2023 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "OGTKReceivedNilExpectedStringException.h"

@implementation OGTKReceivedNilExpectedStringException
@synthesize parameterName = _parameterName;

- (instancetype)initForParameter:(OFString *)parameterName
{
	self = [super init];

	@try {
		_parameterName = [parameterName copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

+ (instancetype)exceptionForParameter:(OFString *)parameterName
{
	return [[[self alloc] initForParameter:parameterName] autorelease];
}

- (void)dealloc
{
	[_parameterName release];
	[super dealloc];
}

- (OFString *)description
{
	if (_parameterName != nil)
		return [OFString
		    stringWithFormat:@"Invalid type: Received nil value as parameter for %@ "
		                     @"but expected instance of OFString.",
		    _parameterName];
	else
		return @"Invalid format: Received nil value as parameter but "
		       @"expected instance of OFString.";
}

@end