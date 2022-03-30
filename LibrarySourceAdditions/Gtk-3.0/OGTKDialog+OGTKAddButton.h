/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKDialog.h"
@class OGTKWindow;

@interface OGTKDialog (OGTKAddButton)

- (id)initWithTitle:(OFString *)title
                          parent:(OGTKWindow *)parent
                           flags:(GtkDialogFlags)flags
    buttonTextResponseDictionary:(OFDictionary *)buttonTextDict;

- (void)addButtons:(OFDictionary *)buttonTextDict;

@end