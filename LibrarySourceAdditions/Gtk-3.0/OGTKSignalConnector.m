/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKSignalConnector.h"

/**
 * Redirects g_signall callbacks to Objective-C class/methods
 */
void gsignal_forwarder(gpointer gtk, OGTKSignalData *data)
{
	[[data target] performSelector:[data selector]];
}

@implementation OGTKSignalConnector

+ (void)connectGpointer:(gpointer)object
             withSignal:(OFString *)name
               toTarget:(id)target
           withSelector:(SEL)selector
                   data:(gpointer)data
{
	/*
	 * Don't release this or else we could seg fault! (Note that to avoid
	 * memory leaks in the case of a short-lived GUI, the application should
	 * maintain references to the OGTKSignalData elsewhere and release it
	 * there when it is no longer needed.)
	 */
	OGTKSignalData *signalData =
	    [[OGTKSignalData alloc] initWithTarget:(id)target
	                                  selector:selector
	                                      data:data];

	g_signal_connect(object, [name UTF8String],
	    G_CALLBACK(gsignal_forwarder), signalData);
}

@end
