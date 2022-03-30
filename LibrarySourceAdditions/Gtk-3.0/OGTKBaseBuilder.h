/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include <gtk/gtk.h>
#include <gtk/gtkx.h>
#include <gtk/gtk-a11y.h>

#import <ObjFW/ObjFW.h>

#import "OGTKBuilder.h"
#import "OGTKCallbackData.h"
#import "OGTKSignalConnector.h"
#import "OGTKWidget.h"

/**
 * OGTKBuilder adds additional functionality to GtkBuilder
 */
@interface OGTKBaseBuilder: OFObject

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
+ (void)connectSignalsToObjectsWithBuilder:(OGTKBuilder *)builder
                          signalDictionary:
                              (OFDictionary *)objectSignalDictionary;

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
+ (OGTKWidget *)getWidgetFromBuilder:(OGTKBuilder *)builder
                            withName:(OFString *)name;

@end
