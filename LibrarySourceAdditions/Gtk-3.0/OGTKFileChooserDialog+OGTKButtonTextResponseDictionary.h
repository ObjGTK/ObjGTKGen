/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKFileChooserDialog.h"
@class OGTKWindow;

@interface OGTKFileChooserDialog (OGTKButtonTextResponseDictionary)

- (id)initWithTitle:(OFString *)title
                          parent:(OGTKWindow *)parent
                          action:(GtkFileChooserAction)action
    buttonTextResponseDictionary:(OFDictionary *)buttonTextDict;

@end