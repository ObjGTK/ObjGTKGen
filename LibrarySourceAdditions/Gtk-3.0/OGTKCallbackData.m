/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKCallbackData.h"

@implementation OGTKCallbackData
@synthesize object = _object, selector = _selector;

+ (instancetype)callbackWithObject:(id)object selector:(SEL)selector
{
	return [[[OGTKCallbackData alloc] initWithObject:object
	                                        selector:selector] autorelease];
}

- (instancetype)initWithObject:(id)object selector:(SEL)selector
{
	self = [super init];

	_object = [object retain];
	_selector = selector;

	return self;
}

- (void)dealloc
{
	[_object release];

	[super dealloc];
}

@end
