/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKTypeWrapper.h"

/**
 * Provides functions for wrapping GTK types
 */
@implementation OGTKTypeWrapper

@synthesize gintValue = _gintValue, ptrValue = _ptrValue;

- (const GValue *)asGValuePtr
{
	return (const GValue *)_ptrValue;
}

@end
