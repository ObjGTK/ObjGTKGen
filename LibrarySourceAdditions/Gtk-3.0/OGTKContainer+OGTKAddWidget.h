/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKContainer.h"

@interface OGTKContainer (OGTKAddWidget)

- (void)addWidget:(OGTKWidget *)widget
    withProperties:(OFDictionary *)properties;

@end