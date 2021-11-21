/*
 * OGTKMapper.h
 * This file is part of ObjGTKGen
 *
 * Copyright (C) 2021 - Johannes Brakensiek
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
 */

#import <ObjFW/ObjFW.h>

@class OGTKClass;

@interface OGTKMapper: OFObject
{
	OFMutableDictionary OF_GENERIC(OFString *, OGTKClass *) *
	    _gobjTypeToClassMapping;
	OFMutableDictionary OF_GENERIC(OFString *, OGTKClass *) *
	    _girNameToClassMapping;
	OFMutableDictionary OF_GENERIC(OFString *, OGTKClass *) *
	    _objcTypeToClassMapping;
}

/**
 * @brief Dictionary that maps Gobj type names to class information (OGTKClass)
 */
@property (readonly, nonatomic) OFMutableDictionary OF_GENERIC(
    OFString *, OGTKClass *)
    * gobjTypeToClassMapping;

/**
 * @brief Dictionary that maps general type names that are specified in the .gir
 * file to class information (OGTKClass)
 */
@property (readonly, nonatomic) OFMutableDictionary OF_GENERIC(
    OFString *, OGTKClass *)
    * girNameToClassMapping;

/**
 * @brief Dictionary that maps ObjC type names to class information (OGTKClass)
 */
@property (readonly, nonatomic) OFMutableDictionary OF_GENERIC(
    OFString *, OGTKClass *)
    * objcTypeToClassMapping;

/**
 * @brief Singleton
 * @return instancetype One unique instance of OGTKMapper
 */
+ (instancetype)sharedMapper;

/**
 * @brief Adds a class to the mapping dictionaries
 * @param classInfo The object describing the class
 */
- (void)addClass:(OGTKClass *)classInfo;

/**
 * @brief Removes a class from the mapping dictionaries
 * @param classInfo The object describing the class
 */
- (void)removeClass:(OGTKClass *)classInfo;

/**
 * @brief Iterates through all the class information objects retained in the
 * dict and looks for class dependencies
 * @details Dependencies are stored as Gobj types as well and should be
 * mapped/swapped using this class when actually written out to ObjC files.
 *
 * For this method to work all the class information objects need to be filled
 * with correct data.
 */
- (void)determineDependencies;

/**
 * @brief Iterates through all the dependencies of all the class information
 * objects retained in the dict
 * @details This will only work if ```determineDependencies``` is called before
 * @see -determineDependencies
 */
- (void)detectAndMarkCircularDependencies;

/**
 * @brief Returns if a given type string is listed as Gobj class type
 * @return True if the given string is a listed Gobj class type
 */
- (bool)isGobjType:(OFString *)type;

/**
 * @brief Returns if a given type string is listed as ObjC class type
 * @return True if the given string is a listed ObjC class type
 */
- (bool)isObjcType:(OFString *)type;

/**
 * @brief Tries to swap Gobj data types with ObjC data types and vice versa.
 * Returns the input if it can't.
 * @details In addition to the class information provided via
 * ```addClass:```before this method will also swap basic data types like gchar*
 * and gboolean.
 *
 * Class types of basic (runtime) libraries which Gtk depends on, f.e. Glib, are
 * always mapped to OGObject because we do not want to wrap and use those but
 * use ObjFW classes instead.
 *
 * Pointers to pointer (**) currently are not swapped because conversion of
 * these types is not yet implemented by ```convertType:withName:toType```.
 * @see -convertType:withName:toType
 *
 */
- (OFString *)swapTypes:(OFString *)type;

/**
 * @brief Tests if the given type is swappable by ```swapTypes:```
 * @param type The Gobj or ObjC type name
 * @return True if the given type is swappable by ```swapTypes:```
 */
- (bool)isTypeSwappable:(OFString *)type;

/**
 * @brief Provides the string holding the source code snipped to convert
 * ```fromType``` to ```toType``` holding ```name``` as variable name
 * @details This method is the corresponding part to ```swapTypes:```. While
 * that swaps type names this is meant to provide the code snipped string needed
 * to transfor one type to the other.
 * @param fromType The Gobj or ObjC type name to provide conversion code for.
 * @param name The name of the variable in the source code, defined by fromType.
 * @param toType The ObjC or Gobj type name which the returned code should
 * convert to.
 * @return The source code needed to convert ```fromType``` to
 * ```toType``` holding ```name``` as variable name
 *
 */
- (OFString *)convertType:(OFString *)fromType
                 withName:(OFString *)name
                   toType:(OFString *)toType;

/**
 * @brief Returns the appropriate self referencing method call for the type
 * (i.e. -(type)[self TYPE] or GTK_TYPE([self GOBJECT]) to unwrap the Gobj
 * object instance
 * @param type The Gobj or ObjC class name for which the method call should be
 * generated.
 * @return The code snipped holding the method call snipped to unwrap the Gobj
 * object instance.
 *
 */
- (OFString *)selfTypeMethodCall:(OFString *)type;

/**
 * @brief Returns the cType (Gobj type) for a name provided by a gir file
 * @details In some cases the gir files do not provide cTypes (Gobj/Glib type
 * names). Then this method may be used to retrieve the correct cType for gir
 * class (name) definition.
 *
 * This only works if the necessary class information has been provided using
 * ```addClass:``` before.
 * @see -addClass:
 *
 */
- (OFString *)getCTypeFromName:(OFString *)name;

/**
 * @brief Return is ```type``` is known by the Gobj type dict
 *
 */
+ (bool)isGobjType:(OFString *)type;

/**
 * @brief Return is ```type``` is known by the ObjC type dict
 *
 */
+ (bool)isObjcType:(OFString *)type;

/**
 * @brief Tries to swap Gobj data types with ObjC data types and vice versa.
 * Returns the input if it can't. Singleton access shortcut.
 * @see -swapTypes:
 */
+ (OFString *)swapTypes:(OFString *)type;

/**
 * @brief Tests if the given type is swappable by ```swapTypes:``` Singleton
 * access shortcut.
 * @see -isTypeSwappable:
 */
+ (bool)isTypeSwappable:(OFString *)type;

/**
 * @brief Provides the string holding the source code snipped to convert
 * ```fromType``` to ```toType``` holding ```name``` as variable name. Singleton
 * access shortcut.
 * @see -convertType:withName:toType:
 */
+ (OFString *)convertType:(OFString *)fromType
                 withName:(OFString *)name
                   toType:(OFString *)toType;

/**
 * @brief Returns the appropriate self referencing method call for the type
 * (i.e. -(type)[self TYPE] or GTK_TYPE([self GOBJECT]) to unwrap the Gobj
 * object instance. Singleton access shortcut.
 * @see -selfTypeMethodCall:
 */
+ (OFString *)selfTypeMethodCall:(OFString *)type;

/**
 * @brief Returns the appropriate self referencing method call for the type
 * (i.e. -(type)[self TYPE] or GTK_TYPE([self GOBJECT]) to unwrap the Gobj
 * object instance. Singleton access shortcut.
 * @see -getCTypeFromName:
 */
+ (OFString *)getCTypeFromName:(OFString *)name;

@end
