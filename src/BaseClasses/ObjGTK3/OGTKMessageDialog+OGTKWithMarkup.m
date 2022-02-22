/*
 * OGTKMessageDialog+OGTKWithMarkup.m
 * This file is part of ObjGTK which is a fork of CoreGTK for ObjFW
 *
 * Copyright (C) 2017 - Tyler Burton
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
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