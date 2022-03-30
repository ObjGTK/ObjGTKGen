/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKSignalData.h"
#import <ObjFW/ObjFW.h>
#import <gtk/gtk.h>

void gsignal_forwarder(gpointer gtk, OGTKSignalData *data);

/**
 * Provides functions for GCallback signal connecting
 */
@interface OGTKSignalConnector: OFObject

/**
 * Connects a GCallback function to a signal for a particular object. The
 * GCallback function redirects the call to the Objective-C target and selector.
 *
 * @param object
 *  The instance to connect to
 *
 * @param name
 *  The signal name to connect (a string in the form of "signal-name::detail"
 *
 * @param target
 *  The Objective-C class to callback to
 *
 * @param sel
 *  The selector
 *
 * @param data
 *  The data to pass to c_handler calls
 *
 * @returns a new OGTKCallbackData
 */
+ (void)connectGpointer:(gpointer)object
             withSignal:(OFString *)name
               toTarget:(id)target
           withSelector:(SEL)selector
                   data:(gpointer)data;

@end
