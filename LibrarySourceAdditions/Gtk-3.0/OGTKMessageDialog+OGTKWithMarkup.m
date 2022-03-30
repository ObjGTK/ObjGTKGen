/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKMessageDialog+OGTKWithMarkup.h"
#import "OGTKWindow.h"

@implementation OGTKMessageDialog (OGTKWithMarkup)

- (id)initWithParent:(OGTKWindow *)parent
               flags:(GtkDialogFlags)flags
                type:(GtkMessageType)type
             buttons:(GtkButtonsType)buttons
              markup:(OFString *)markup
{
	self = [super
	    initWithGObject:(GObject *)gtk_message_dialog_new_with_markup(
	                        [parent WINDOW], flags, type, buttons,
	                        [markup UTF8String], NULL)];

	return self;
}

- (void)formatSecondaryMarkup:(OFString *)markup
{
	gtk_message_dialog_format_secondary_markup(
	    [self MESSAGEDIALOG], [markup UTF8String], NULL);
}

- (void)formatSecondaryText:(OFString *)message
{
	gtk_message_dialog_format_secondary_text(
	    [self MESSAGEDIALOG], [message UTF8String], NULL);
}

- (id)initWithParent:(OGTKWindow *)parent
               flags:(GtkDialogFlags)flags
                type:(GtkMessageType)type
             buttons:(GtkButtonsType)buttons
             message:(OFString *)message
{
	self = [super initWithGObject:(GObject *)gtk_message_dialog_new(
	                                  [parent WINDOW], flags, type, buttons,
	                                  [message UTF8String], NULL)];

	return self;
}

@end