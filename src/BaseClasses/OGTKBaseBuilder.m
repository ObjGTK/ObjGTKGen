/*
 * OGTKBaseBuilder.m
 * This file is part of ObjGTK
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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 */

#import "OGTKBaseBuilder.h"

static bool OGTKBuilderDebugMode = false;

static void gtkbuilder_connect_signals_handler(GtkBuilder* builder,
    GObject* object, const gchar* signal_name, const gchar* handler_name,
    GObject* connect_object, GConnectFlags flags, gpointer user_data)
{
    if (OGTKBuilderDebugMode) {
        OFLog(@"Signal_name = %@", [OFString stringWithUTF8String:signal_name]);
        OFLog(@"Handlers_name = %@",
            [OFString stringWithUTF8String:handler_name]);
    }

    OFDictionary* objectSignalDictionary = (OFDictionary*)user_data;

    id callbackData = [objectSignalDictionary
        objectForKey:[OFString stringWithUTF8String:handler_name]];

    id obj = [callbackData object];
    SEL sel = [callbackData selector];

    if (obj == nil && object != NULL) {
        if (OGTKBuilderDebugMode) {
            OFLog(@"Connecting to plain C function");
        }
        // Connect to C function
        g_signal_connect(object, signal_name, G_CALLBACK(handler_name), NULL);
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
                    andData:NULL];
    }
}

@implementation OGTKBaseBuilder

+ (void)setDebug:(bool)debugEnabled
{
    OGTKBuilderDebugMode = debugEnabled;
}

+ (void)connectSignalsToObjectsWithBuilder:(OGTKBuilder*)builder
                       andSignalDictionary:
                           (OFDictionary*)objectSignalDictionary;
{
    gtk_builder_connect_signals_full([builder BUILDER],
        &gtkbuilder_connect_signals_handler, objectSignalDictionary);
}

+ (OGTKWidget*)getWidgetFromBuilder:(OGTKBuilder*)builder
                           withName:(OFString*)name
{
    GObject* obj = gtk_builder_get_object([builder BUILDER], [name UTF8String]);

    if (GTK_IS_WIDGET(obj)) {
        return [[[OGTKWidget alloc] initWithGObject:obj] autorelease];
    } else {
        return nil;
    }
}

@end
