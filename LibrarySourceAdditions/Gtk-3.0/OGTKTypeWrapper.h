/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include <gtk/gtk.h>
#include <gtk/gtkx.h>
#include <gtk/gtk-a11y.h>

#import <ObjFW/ObjFW.h>

/**
 * Provides functions for wrapping GTK types
 */
@interface OGTKTypeWrapper: OFObject
{
	void *_ptrValue;
	gint _gintValue;
}

@property (nonatomic) gint gintValue;
@property (nonatomic) void *ptrValue;

/**
 * Returns the stored ptrValue as a GValue*
 *
 * @returns GValue*
 */
- (const GValue *)asGValuePtr;

@end
