/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTKBaseBuilder.h"

static bool OGTKBuilderDebugMode = false;

static void gtkbuilder_connect_signals_handler(GtkBuilder *builder,
    GObject *object, const gchar *signal_name, const gchar *handler_name,
    GObject *connect_object, GConnectFlags flags, gpointer user_data)
{
	if (OGTKBuilderDebugMode) {
		OFLog(@"Signal_name = %@",
		    [OFString stringWithUTF8String:signal_name]);
		OFLog(@"Handlers_name = %@",
		    [OFString stringWithUTF8String:handler_name]);
	}

	OFDictionary *objectSignalDictionary = (OFDictionary *)user_data;

	id callbackData = [objectSignalDictionary
	    objectForKey:[OFString stringWithUTF8String:handler_name]];

	id obj = [callbackData object];
	SEL sel = [callbackData selector];

	if (obj == nil && object != NULL) {
		if (OGTKBuilderDebugMode) {
			OFLog(@"Connecting to plain C function");
		}
		// Connect to C function
		g_signal_connect(
		    object, signal_name, G_CALLBACK(handler_name), NULL);
	} else {
		if (OGTKBuilderDebugMode) {
			OFLog(@"Found object %@", obj);
		}

		// Connect to Objective-C method
		[OGTKSignalConnector
		    connectGpointer:object
		         withSignal:[OFString stringWithUTF8String:signal_name]
		           toTarget:obj
		       withSelector:sel
		               data:NULL];
	}
}

@implementation OGTKBaseBuilder

+ (void)setDebug:(bool)debugEnabled
{
	OGTKBuilderDebugMode = debugEnabled;
}

+ (void)connectSignalsToObjectsWithBuilder:(OGTKBuilder *)builder
                          signalDictionary:
                              (OFDictionary *)objectSignalDictionary
{	
	gtk_builder_connect_signals_full([builder BUILDER],
	    &gtkbuilder_connect_signals_handler, objectSignalDictionary);
}

+ (OGTKWidget *)getWidgetFromBuilder:(OGTKBuilder *)builder
                            withName:(OFString *)name
{
	GObject *obj =
	    gtk_builder_get_object([builder BUILDER], [name UTF8String]);

	if (GTK_IS_WIDGET(obj)) {
		return [[[OGTKWidget alloc] initWithGObject:obj] autorelease];
	} else {
		return nil;
	}
}

@end
