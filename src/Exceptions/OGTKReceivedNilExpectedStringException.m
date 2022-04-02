/*
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2021-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "OGTKReceivedNilExpectedStringException.h"

@implementation OGTKReceivedNilExpectedStringException

- (OFString *)description
{
	return @"Wrong format: Received nil value as parameter but expected "
	       @"instance of OFString.";
}

@end