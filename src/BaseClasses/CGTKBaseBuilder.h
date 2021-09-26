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

#import "CGTKBuilder.h"
#import "CGTKCallbackData.h"
#import "CGTKSignalConnector.h"
#import "CGTKWidget.h"

/**
 * CGTKBuilder adds additional functionality to GtkBuilder
 */
@interface CGTKBaseBuilder : OFObject {
}

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
 *  [CallbackData withObject:[CGTK class] andSEL:@selector(endMainLoop)],
 *  @"mainQuit", 
 *  [CallbackData withObject:button andSEL:@selector(clicked)],
 *  @"on_button1_activate", 
 *  [CallbackData withObject:button andSEL:@selector(clicked)], 
 *  @"on_button2_clicked", nil];
 *
 * [builder connectSignalsToObjects:dict];
 *
 * @param builder
 * A CGTKBuilder to use while attaching signals
 *
 * @param objectSignalDictionary
 *  A dictionary mapping CallbackData objects to OFString signal names
 */
+ (void)connectSignalsToObjectsWithBuilder:(CGTKBuilder*)builder andSignalDictionary:(OFDictionary*)objectSignalDictionary;

/**
 * Attempts to get the object witht he name returning it as a CGTKWidget. If the 
 * object is not found or not compatible with CGTKWidget this will return nil.
 *
 *
 * @param builder
 * the builder to get the widget from
 *
 * @param name
 *  the name of the object to return
 *
 * @returns the CGTKWidget or nil
 */
+ (CGTKWidget*)getWidgetFromBuilder:(CGTKBuilder*)builder withName:(OFString*)name;

@end
