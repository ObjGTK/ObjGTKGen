/*
 * CGTKUtil.h
 * This file is part of CoreGTKGen
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
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 */

#import <ObjFW/ObjFW.h>
#import "OFDictionary+JsonContentsOfFile.h"
#import "../Exceptions/OGTKReceivedNilExpectedStringException.h"

/**
 * Provides useful utility functions for CoreGTKGen
 */
@interface CGTKUtil : OFObject {
}

/**
 * Returns the underscore_separated_string in camelCase 
 */
+ (OFString*)convertUSSToCamelCase:(OFString*)input;

/**
 * Returns the underscore_separated_string in CapitalCase
 */
+ (OFString*)convertUSSToCapCase:(OFString*)input;

/**
 * Tests if a character is uppercase
 */
+ (bool)isUppercase:(OFString*)character;

/**
 * Returns true if this type is configured as being swappable
 */
+ (bool)isTypeSwappable:(OFString*)str;

/**
 * Attempts to swap the type or returns the input if it can't
 */
+ (OFString*)swapTypes:(OFString*)str;

/**
 * Converts GTK style type_new_with_param style functions into CoreGTK initWithParam inits. If func doesn't contain "New" or "new" then it will return nil.
 */
+ (OFString*)convertFunctionToInit:(OFString*)func;

/**
 * Returns a super constructor call for the given type. While it takes a cType it currently assumes everything is a GObject (FOR FUTURE USE).
 */
+ (OFString*)getFunctionCallForConstructorOfType:(OFString*)cType withConstructor:(OFString*)cCtor;

/**
 * Converts the given fromType to the toType while maintaining the name
 */
+ (OFString*)convertType:(OFString*)fromType withName:(OFString*)name toType:(OFString*)toType;

/**
 * Returns the appropriate self referencing call for the type (i.e. -(type)[self TYPE] or GTK_TYPE([self GOBJECT])
 */
+ (OFString*)selfTypeMethodCall:(OFString*)type;

/**
 * Adds the prefix to the trimmed method name list
 */
+ (void)addToTrimMethodName:(OFString*)val;

/**
 * Trims method name (i.e. removes things like GTK_)
 */
+ (OFString*)trimMethodName:(OFString*)meth;

/**
 * Gets a list of extra imports for the class
 */
+ (OFArray*)extraImports:(OFString*)clazz;

/**
 * Gets a list of extra methods for the class
 */
+ (OFDictionary*)extraMethods:(OFString*)clazz;

/**
 * Returns the configuration value for the provided key
 */
+ (id)globalConfigValueFor:(OFString*)key;

@end
