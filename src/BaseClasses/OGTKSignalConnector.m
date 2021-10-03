/*
 * OGTKSignalConnector.m
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

#import "OGTKSignalConnector.h"

/**
 * Redirects g_signall callbacks to Objective-C class/methods
 */
void gsignal_forwarder(gpointer gtk, OGTKSignalData* data)
{
    [[data target] performSelector:[data selector]];
}

@implementation OGTKSignalConnector

+ (void)connectGpointer:(gpointer)object
             withSignal:(OFString*)name
               toTarget:(id)target
           withSelector:(SEL)selector
                andData:(gpointer)data
{
    /*
     * Don't release this or else we could seg fault! (Note that to avoid memory
     * leaks in the case of a short-lived GUI, the application should maintain
     * references to the OGTKSignalData elsewhere and release it there when it
     * is no longer needed.)
     */
    OGTKSignalData* signalData =
        [[OGTKSignalData alloc] initWithTarget:(id)target
                                      selector:selector
                                          data:data];

    g_signal_connect(
        object, [name UTF8String], G_CALLBACK(gsignal_forwarder), signalData);
}

@end
