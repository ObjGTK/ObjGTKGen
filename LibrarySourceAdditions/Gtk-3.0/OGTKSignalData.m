/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKSignalData.h"

@implementation OGTKSignalData: OFObject
@synthesize target = _target, selector = _selector, data = _data;
@synthesize dataRetained = _retained;

- (instancetype)initWithTarget:(id)target
                      selector:(SEL)selector
                          data:(void *)data
{
	self = [super init];

	_target = [target retain];
	_selector = selector;
	_data = data;

	return self;
}

@end
