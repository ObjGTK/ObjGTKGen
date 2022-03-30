/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKInfoBar+OGTKAddButtonTextResponseDictionary.h"
#import "OGTKTypeWrapper.h"

@implementation OGTKInfoBar (OGTKAddButtonTextResponseDictionary)

- (id)initWithButtonTextResponseDictionary:(OFDictionary *)buttonTextDict
{
	self = [super initWithGObject:(GObject *)gtk_info_bar_new()];

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

- (void)addButtonTextResponseDictionary:(OFDictionary *)buttonTextDict
{
	OGTKTypeWrapper *wrapper;

	for (OFString *text in buttonTextDict) {
		wrapper = [buttonTextDict objectForKey:text];

		[self addButtonWithButtonText:text
		                   responseId:wrapper.gintValue];
	}
}

@end