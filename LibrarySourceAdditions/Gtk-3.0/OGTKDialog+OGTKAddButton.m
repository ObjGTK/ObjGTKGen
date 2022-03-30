/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKDialog+OGTKAddButton.h"
#import "OGTKTypeWrapper.h"
#import "OGTKWindow.h"

@implementation OGTKDialog (OGTKAddButton)

- (id)initWithTitle:(OFString *)title
                          parent:(OGTKWindow *)parent
                           flags:(GtkDialogFlags)flags
    buttonTextResponseDictionary:(OFDictionary *)buttonTextDict
{
	self = [super initWithGObject:(GObject *)gtk_dialog_new_with_buttons(
	                                  [title UTF8String], [parent WINDOW],
	                                  flags, NULL, NULL)];

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

- (void)addButtons:(OFDictionary *)buttonTextDict
{
	OGTKTypeWrapper *wrapper;
	for (OFString *text in buttonTextDict) {
		wrapper = [buttonTextDict objectForKey:text];

		[self addButtonWithButtonText:text
		                   responseId:wrapper.gintValue];
	}
}
@end