/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import "OGTK.h"

OFString *const OGTKVersion = @"0.1";

@implementation OGTK

+ (OFString *)objGtkVersion
{
	return OGTKVersion;
}

+ (OFString *)gtkVersion
{
	return [OFString stringWithFormat:@"%i.%i.%i", gtk_get_major_version(),
	                 gtk_get_minor_version(), gtk_get_micro_version()];
}

+ (void)initWithArgc:(int *)argc argv:(char ***)argv
{
	gtk_init(argc, argv);
}

+ (int)autoInitWithArgc:(int)argc argv:(char *[])argv
{
	[OGTK initWithArgc:&argc argv:&argv];
	return argc;
}

+ (void)main
{
	gtk_main();
}

+ (void)mainQuit
{
	gtk_main_quit();
}

@end
