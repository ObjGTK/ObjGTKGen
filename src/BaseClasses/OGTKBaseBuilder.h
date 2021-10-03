/*
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

#import <ObjFW/ObjFW.h>

#import "OGTKBuilder.h"
#import "OGTKCallbackData.h"
#import "OGTKSignalConnector.h"
#import "OGTKWidget.h"

/**
 * OGTKBuilder adds additional functionality to GtkBuilder
 */
@interface OGTKBaseBuilder : OFObject

/**
 * When enabled this builder will print out signal connection debug info
 */
+ (void)setDebug:(bool)debugEnabled;

/**
 * Similar to the other connect signals functions, this takes a dictionary key'd
 * on CallbackData objects (configured with class/selectors) and their
 * associated signals as values and connects them accordingly.
 *
 * Example usage:
 *  OFDictionary *dict = [[OFDictionary alloc] initWithObjectsAndKeys:
 *  [CallbackData withObject:[OGTK class] selector:@selector(endMainLoop)],
 *  @"mainQuit",
 *  [CallbackData withObject:button selector:@selector(clicked)],
 *  @"on_button1_activate",
 *  [CallbackData withObject:button selector:@selector(clicked)],
 *  @"on_button2_clicked", nil];
 *
 * [builder connectSignalsToObjects:dict];
 *
 * @param builder
 * A OGTKBuilder to use while attaching signals
 *
 * @param objectSignalDictionary
 *  A dictionary mapping CallbackData objects to OFString signal names
 */
+ (void)connectSignalsToObjectsWithBuilder:(OGTKBuilder*)builder
                       andSignalDictionary:
                           (OFDictionary*)objectSignalDictionary;

/**
 * Attempts to get the object witht he name returning it as a OGTKWidget. If the
 * object is not found or not compatible with OGTKWidget this will return nil.
 *
 *
 * @param builder
 * the builder to get the widget from
 *
 * @param name
 *  the name of the object to return
 *
 * @returns the OGTKWidget or nil
 */
+ (OGTKWidget*)getWidgetFromBuilder:(OGTKBuilder*)builder
                           withName:(OFString*)name;

@end
