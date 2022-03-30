/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKContainer.h"

@interface OGTKContainer (OGTKAddWidget)

- (void)addWidget:(OGTKWidget *)widget
    withProperties:(OFDictionary *)properties;

@end