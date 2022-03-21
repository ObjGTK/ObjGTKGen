/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKInfoBar.h"

@interface OGTKInfoBar (OGTKAddButtonTextResponseDictionary)

- (id)initWithButtonTextResponseDictionary:(OFDictionary *)buttonTextDict;

- (void)addButtonTextResponseDictionary:(OFDictionary *)buttonTextDict;

@end