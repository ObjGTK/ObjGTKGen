/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKFileChooserDialog+OGTKButtonTextResponseDictionary.h"
#import "OGTKTypeWrapper.h"
#import "OGTKWindow.h"

@implementation OGTKFileChooserDialog (OGTKButtonTextResponseDictionary)

- (id)initWithTitle:(OFString *)title
                          parent:(OGTKWindow *)parent
                          action:(GtkFileChooserAction)action
    buttonTextResponseDictionary:(OFDictionary *)buttonTextDict
{
	self = [super initWithGObject:(GObject *)gtk_file_chooser_dialog_new(
	                                  [title UTF8String], [parent WINDOW],
	                                  action, NULL, NULL)];

	@try {
		OGTKTypeWrapper *wrapper;

		for (OFString *text in buttonTextDict) {
			wrapper = [buttonTextDict objectForKey:text];

			[self addButtonWithButtonText:text
			                   responseId:wrapper.gintValue];
		}

	} @catch (id e) {
		[self release];
		@throw e;
	}
	return self;
}

@end