/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import <OGObject/OGObject.h>
#import <gtk/gtk.h>

extern OFString *const OGTKVersion;

/**
 * Global level CoreGTK functionality
 */
@interface OGTK: OFObject

/**
 * Returns the CoreGTK version string
 *
 * @return the version string
 */
+ (OFString *)objGtkVersion;

/**
 * Returns the GTK version string
 *
 * @return the version string
 */
+ (OFString *)gtkVersion;

/**
 * Call this function before using any other GTK+ functions in your GUI
 * applications. It will initialize everything needed to operate the toolkit and
 * parses some standard command line options.
 *
 * Although you are expected to pass the argc, argv parameters from main() to
 * this function, it is possible to pass NULL if argv is not available or
 * commandline handling is not required.
 *
 * argc and argv are adjusted accordingly so your own code will never see those
 * standard arguments.
 *
 * @param argc
 *  Address of the argc parameter of your main() function (or 0 if argv is
 *  NULL). This will be changed if any arguments were handled. [inout]
 *
 * @param argv
 *  Address of the argv parameter of main(), or NULL. Any options understood by
 *  GTK+ are stripped before return. [array length=argc][inout][allow-none]
 */
+ (void)initWithArgc:(int *)argc argv:(char ***)argv;

/**
 * Same as initWithArgc:andArgv: but does the type conversion automatically.
 *
 * @param argc
 *  Address of the argc parameter of your main() function (or 0 if argv is
 *  NULL). This will be changed if any arguments were handled. [inout]
 *
 * @param argv
 *  Address of the argv parameter of main(), or NULL. Any options understood by
 *  GTK+ are stripped before return. [array length=argc][inout][allow-none]
 *
 * @returns modified argc value
 *
 * @see initWithArgc:andArgv:
 */
+ (int)autoInitWithArgc:(int)argc argv:(char *[])argv;

/**
 * Runs the main loop until mainQuit is called.
 * You can nest calls to main. In that case mainQuit will make the innermost
 * invocation of the main loop return.
 *
 * @see mainQuit
 */
+ (void)main;

/**
 * Makes the innermost invocation of the main loop return when it regains
 * control.
 */
+ (void)mainQuit;

@end
