/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKRecentChooserDialog.h"
@class OGTKWindow;

@interface OGTKRecentChooserDialog (OGTKButtonTextResponseDictionary)

- (id)initWithTitle:(OFString *)title
                          parent:(OGTKWindow *)parent
    buttonTextResponseDictionary:(OFDictionary *)buttonTextDict;

- (id)initForManagerWithTitle:(OFString *)title
                          parent:(OGTKWindow *)parent
                         manager:(GtkRecentManager *)manager
    buttonTextResponseDictionary:(OFDictionary *)buttonTextDict;

@end