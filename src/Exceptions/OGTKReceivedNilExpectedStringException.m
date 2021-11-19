/*
 * Copyright 2021 Johannes Brakensiek <letterus at codingpastor.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "OGTKReceivedNilExpectedStringException.h"

@implementation OGTKReceivedNilExpectedStringException

- (OFString *)description
{
	return @"Wrong format: Received nil value as parameter but expected "
	       @"instance of OFString.";
}

@end