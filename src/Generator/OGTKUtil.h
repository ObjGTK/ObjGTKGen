/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import <ObjFW/ObjFW.h>

/**
 * Provides useful utility functions for ObjGTKGen
 */
@interface OGTKUtil: OFObject

/**
 * Returns the underscore_separated_string in camelCase
 */
+ (OFString *)convertUSSToCamelCase:(OFString *)input;

/**
 * Returns the underscore_separated_string in CapitalCase
 */
+ (OFString *)convertUSSToCapCase:(OFString *)input;

/**
 * Tests if a character is uppercase
 */
+ (bool)isUppercase:(OFString *)character;

/**
 * Converts GTK style type_new_with_param style functions into ObjGTK
 * initWithParam inits. If func doesn't contain "New" or "new" then it will
 * return nil.
 */
+ (OFString *)convertFunctionToInit:(OFString *)func;

/**
 * Returns a super constructor call for the given type. While it takes a cType
 * it currently assumes everything is a GObject (FOR FUTURE USE).
 */
+ (OFString *)getFunctionCallForConstructorOfType:(OFString *)cType
                                  withConstructor:(OFString *)cCtor;

/**
 * Returns the configuration value for the provided key
 */
+ (id)globalConfigValueFor:(OFString *)key;

/**
 * Returns the configuration for the library identified by namespaceName-versionNumber
 */
+ (id)libraryConfigFor:(OFString *)libraryIdentifier;

@end
