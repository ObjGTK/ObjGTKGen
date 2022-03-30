/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKMessageDialog.h"
@class OGTKWindow;

@interface OGTKMessageDialog (OGTKWithMarkup)

- (id)initWithParent:(OGTKWindow *)parent
               flags:(GtkDialogFlags)flags
                type:(GtkMessageType)type
             buttons:(GtkButtonsType)buttons
              markup:(OFString *)markup;

- (void)formatSecondaryMarkup:(OFString *)markup;

- (void)formatSecondaryText:(OFString *)message;

- (id)initWithParent:(OGTKWindow *)parent
               flags:(GtkDialogFlags)flags
                type:(GtkMessageType)type
             buttons:(GtkButtonsType)buttons
             message:(OFString *)message;

@end