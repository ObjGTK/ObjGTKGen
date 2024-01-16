/*
 * SPDX-FileCopyrightText: 2024 Johannes Brakensiek <objfw@devbeejohn.de>
 * SPDX-FileCopyrightText: 2024 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "OGTKGIRNoPackageException.h"

@implementation OGTKGIRNoPackageException

- (OFString *)description
{
	return @"The current GIR file is missing a \"package\" tag/element. ObjGTK relies on "
	       @"pkg-config to create working Makefiles and thus needs a package name.";
}
@end