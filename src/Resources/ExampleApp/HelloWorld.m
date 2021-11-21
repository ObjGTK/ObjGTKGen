/*
 * HelloWorld.m
 * This file is part of ObjGTKGen
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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 *
 */

#import <ObjFW/ObjFW.h>

#import "ObjGTK/OGTK.h"
#import "ObjGTK/OGTKBaseBuilder.h"
#import "ObjGTK/OGTKBuilder.h"
#import "ObjGTK/OGTKButton.h"
#import "ObjGTK/OGTKCallbackData.h"
#import "ObjGTK/OGTKSignalConnector.h"
#import "ObjGTK/OGTKWindow.h"

@interface HelloWorld: OFObject

/* This is a callback function. The data arguments are ignored
 * in this example. More callbacks below. */
+ (void)hello;

+ (void)goodbye;

/* Another callback */
+ (void)destroy;

+ (void)gladeExample;

+ (void)standardExample;

@end

@implementation HelloWorld

int main(int argc, char *argv[])
{
	/* This is called in all GTK applications. Arguments are parsed
	 * from the command line and are returned to the application. */
	[OGTK autoInitWithArgc:argc argv:argv];

	// Show standard example
	[HelloWorld standardExample];

	// Show GLADE example
	[HelloWorld gladeExample];

	return 0;
}

/*
 * This is an example program showing some ObjGTK features
 */
+ (void)standardExample  //(int argc, char *argv[])
{
	/* We could use also OGTKWidget here instead */
	OGTKWindow *window;
	OGTKButton *button;

	/* Create a new window */
	window = [[OGTKWindow alloc] init:GTK_WINDOW_TOPLEVEL];

	/* Here we connect the "destroy" event to a signal handler in the
	 * HelloWorld class */
	[OGTKSignalConnector connectGpointer:[window WIDGET]
	                          withSignal:@"destroy"
	                            toTarget:[OGTK class]
	                        withSelector:@selector(mainQuit)
	                                data:NULL];

	/* Sets the border width of the window */
	[window setBorderWidth:10];

	/* Sets the title text of the window */
	[window
	    setTitle:[OFString stringWithFormat:@"This is ObjGTK %@ supporting "
	                                        @"GTK+ %@!",
	                       [OGTK objGtkVersion], [OGTK gtkVersion]]];

	/* Sets the default size to 400x300 */
	[window setDefaultSizeWithWidth:400 height:300];

	/* Creates a new button with the label "Hello World" */
	button = [[OGTKButton alloc] initWithLabel:@"Hello World"];

	/* When the button receives the "clicked" signal, it will call the
	 * function hello() in the HelloWorld class (below) */
	[OGTKSignalConnector connectGpointer:[button WIDGET]
	                          withSignal:@"clicked"
	                            toTarget:[HelloWorld class]
	                        withSelector:@selector(hello)
	                                data:NULL];

	/* This packs the button into the window (a gtk container) */
	[window add:button];

	/* The final step is to display this newly created widget */
	[button show];

	/* and the window */
	[window show];

	/* All GTK applications must have a [OGTK main] call. Control ends here
	 * and waits for an event to occur (like a key press or
	 * mouse event). */
	[OGTK main];

	/*
	 * Release allocated memory
	 */
	[window release];
}

/*
 * This is an example program showing how to use GLADE with ObjGTK
 */
+ (void)gladeExample
{
	/* Create a builder to load GLADE file */
	OGTKBuilder *builder = [[OGTKBuilder alloc] init];

	if ([builder addFromFileWithFilename:@"gladeExample.glade"
	                                 err:NULL] == 0) {
		OFLog(@"Error loading GUI file");
		return;
	}

	/* Turn debug mode on so we can see signal connecting messages */
	[OGTKBaseBuilder setDebug:true];

	/* Use signal dictionary to connect GLADE objects to Objective-C code */
	OFDictionary *dic = [[OFDictionary alloc]
	    initWithKeysAndObjects:@"endGtkLoop",
	    [OGTKCallbackData callbackWithObject:[OGTK class]
	                                selector:@selector(mainQuit)],
	    @"on_button1_clicked",
	    [OGTKCallbackData callbackWithObject:[HelloWorld class]
	                                selector:@selector(hello)],
	    @"on_button2_clicked",
	    [OGTKCallbackData callbackWithObject:[HelloWorld class]
	                                selector:@selector(goodbye)],
	    nil];

	/* OGTKBaseBuilder is a helper class to maps GLADE signals to
	 * Objective-C code */
	[OGTKBaseBuilder connectSignalsToObjectsWithBuilder:builder
	                                   signalDictionary:dic];

	/* window is autoreleased */
	OGTKWidget *window = [OGTKBaseBuilder getWidgetFromBuilder:builder
	                                                  withName:@"window1"];
	if (window != nil) {
		[window showAll];
	}

	/*
	 * Release allocated memory
	 */
	[builder release];

	/* All GTK applications must have a [OGTK main] call. Control ends here
	 * and waits for an event to occur (like a key press or
	 * mouse event). */
	[OGTK main];
}

/*
 * Callback to print hello to console
 */
+ (void)hello
{
	OFLog(@"Hello World");
}

/*
 * Callback to print goodbye to console
 */
+ (void)goodbye
{
	OFLog(@"Goodbye!");
}

/*
 * Callback to exit GTK loop
 */
+ (void)destroy
{
	[OGTK mainQuit];
}

@end
