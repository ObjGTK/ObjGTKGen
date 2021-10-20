/*
 * Copyright 2021 Johannes Brakensiek <letterus at codingpastor.de>
 *
 * This software is licensed under the GNU General Public License
 * (version 2.0 or later). See the LICENSE file in this distribution.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#import "OGTKGObjectInitializationFailedException.h"

@implementation OGTKGObjectInitializationFailedException

- (OFString*)description
{
    if (_inClass != Nil)
        return
            [OFString stringWithFormat:
                          @"Initialization of GObject instance (or a child "
                          @"instance) to be wrapped failed for or in class %@! "
                          @" Received NULL for OGTKObject initalization.",
                      _inClass];
    else
        return @"Initialization of GObject instance (or a child instance) to "
               @"be wrapped failed. Received NULL for OGTKObject "
               @"initalization.";
}

@end