/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKContainer+OGTKAddWidget.h"
#import "OGTKTypeWrapper.h"

@implementation OGTKContainer (OGTKAddWidget)

- (void)addWidget:(OGTKWidget *)widget withProperties:(OFDictionary *)properties
{
	OGTKTypeWrapper *wrapper;
	for (OFString *propName in properties) {
		wrapper = [properties objectForKey:propName];

		gtk_container_child_set_property([self CONTAINER],
		    [widget WIDGET], [propName UTF8String],
		    [wrapper asGValuePtr]);
	}
}

@end