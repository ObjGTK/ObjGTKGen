/*
 * CGTKUtil.m
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

/*
 * Objective-C imports
 */
#import "CGTKUtil.h"
#include <ObjFW/OFObject.h>
#include <ObjFW/OFString.h>

@implementation CGTKUtil

static OFMutableArray* arrTrimMethodName;
static OFMutableDictionary* dictConvertType;
static OFMutableDictionary* dictGlobalConf;
static OFMutableDictionary* dictSwapTypes;
static OFMutableDictionary* dictExtraImports;
static OFMutableDictionary* dictExtraMethods;

+ (OFString*)convertUSSToCamelCase:(OFString*)input
{
    OFString* output = [self convertUSSToCapCase:input];

    if ([output length] > 1) {
        return [OFString stringWithFormat:@"%@%@", [[output substringToIndex:1] lowercaseString], [output substringFromIndex:1]];
    } else {
        return [output lowercaseString];
    }
}

+ (OFString*)convertUSSToCapCase:(OFString*)input
{
    OFMutableString* output = [[[OFMutableString alloc] init] autorelease];
    OFArray* inputItems = [input componentsSeparatedByString:@"_"];

    bool previousItemWasSingleChar = false;

    for (OFString* item in inputItems) {
        if ([item length] > 1) {
            // Special case where we don't strand single characters
            if (previousItemWasSingleChar) {
                [output appendString:item];
            } else {
                [output appendFormat:@"%@%@", [[item substringToIndex:1] uppercaseString], [item substringFromIndex:1]];
            }
            previousItemWasSingleChar = false;
        } else {
            [output appendString:[item uppercaseString]];
            previousItemWasSingleChar = true;
        }
    }

    return output;
}

+ (bool)isTypeSwappable:(OFString*)str
{
    return [str isEqual:@"OFArray*"] || ![[CGTKUtil swapTypes:str] isEqual:str];
}

+ (OFString*)convertFunctionToInit:(OFString*)func
{
    OFRange range = [func rangeOfString:@"New"];
    if (range.location == OFNotFound) {
        range = [func rangeOfString:@"new"];
    }

    if (range.location == OFNotFound) {
        return nil;
    } else {
        return [OFString stringWithFormat:@"init%@", [func substringFromIndex:range.location + 3]];
    }
}

+ (void)addToTrimMethodName:(OFString*)val
{
    if (arrTrimMethodName == nil) {
        arrTrimMethodName = [[OFMutableArray alloc] init];
    }

    if ([arrTrimMethodName indexOfObject:val] == OFNotFound) {
        [arrTrimMethodName addObject:val];
    }
}

+ (OFString*)trimMethodName:(OFString*)meth
{
    if (arrTrimMethodName == nil) {
        arrTrimMethodName = [[OFMutableArray alloc] init];
    }

    OFString* longestMatch = nil;

    for (OFString* el in arrTrimMethodName) {
        if ([meth hasPrefix:el]) {
            if (longestMatch == nil) {
                longestMatch = el;
            } else if (longestMatch.length < el.length) {
                // Found longer match
                longestMatch = el;
            }
        }
    }

    if (longestMatch != nil) {
        return [meth substringFromIndex:[longestMatch length]];
    }

    return meth;
}

+ (OFString*)getFunctionCallForConstructorOfType:(OFString*)cType withConstructor:(OFString*)cCtor
{
    return [OFString stringWithFormat:@"[super initWithGObject:(GObject *)%@]", cCtor];
}

+ (OFString*)selfTypeMethodCall:(OFString*)type;
{
    int i = 0;

    // Convert CGTKFooBar into [self FOOBAR]
    if ([type hasPrefix:@"CGTK"]) {
        type = [CGTKUtil swapTypes:type];

        return [OFString stringWithFormat:@"[self %@]", [[type substringWithRange:OFRangeMake(3, [type length] - 3)] uppercaseString]];
    }
    // Convert GtkFooBar into GTK_FOO_BAR([self GOBJECT])
    else if ([type hasPrefix:@"Gtk"]) {
        OFMutableString* result = [[OFMutableString alloc] init];

        // Special logic for GTK_GL_AREA
        if ([type isEqual:@"GtkGLArea"]) {
            [result appendString:@"GTK_GL_AREA"];
        } else {
            // Special logic for things like GtkHSV
            int countBetweenUnderscores = 0;

            for (i = 0; i < [type length]; i++) {
                // Current character
                OFString* currentChar = [type substringWithRange:OFRangeMake(i, 1)];

                if (i != 0 && [CGTKUtil isUppercase:currentChar] && countBetweenUnderscores > 1) {
                    [result appendFormat:@"_%@", [currentChar uppercaseString]];
                    countBetweenUnderscores = 0;
                } else {
                    [result appendString:[currentChar uppercaseString]];
                    countBetweenUnderscores++;
                }
            }
        }

        [result appendString:@"([self GOBJECT])"];

        return result;
    } else {
        return type;
    }
}

+ (bool)isUppercase:(OFString*)character
{
    OFUnichar myCharacter = [character characterAtIndex:0];
    if(myCharacter >= 'A' && myCharacter <= 'Z')
        return true;

    return false;
}

+ (OFString*)swapTypes:(OFString*)str
{
    if (dictSwapTypes == nil) {
        dictSwapTypes = [[OFMutableDictionary alloc] initWithContentsOfFile:@"Config/swap_types.map"];
    }

    OFString* val = [dictSwapTypes objectForKey:str];

    return (val == nil) ? str : val;
}

+ (OFString*)convertType:(OFString*)fromType withName:(OFString*)name toType:(OFString*)toType
{
    if (dictConvertType == nil) {
        dictConvertType = [[OFMutableDictionary alloc] initWithContentsOfFile:@"Config/convert_type.map"];
    }

    OFMutableDictionary* outerDict = [dictConvertType objectForKey:fromType];

    if (outerDict == nil) {
        if ([fromType hasPrefix:@"Gtk"] && [toType hasPrefix:@"CGTK"]) {
            // Converting from Gtk -> CGTK
            return [OFString stringWithFormat:@"[[%@ alloc] initWithGObject:(GObject *)%@]", [toType substringWithRange:OFRangeMake(0, [toType length] - 1)], name];
        } else if ([fromType hasPrefix:@"CGTK"] && [toType hasPrefix:@"Gtk"]) {
            // Converting from CGTK -> Gtk
            return [OFString stringWithFormat:@"[%@ %@]", name, [[toType substringWithRange:OFRangeMake(3, [toType length] - 4)] uppercaseString]];
        } else {
            return name;
        }
    }

    OFString* val = [outerDict objectForKey:toType];

    if (val == nil) {
        return name;
    } else {
        return [OFString stringWithFormat:val, name];
    }
}

+ (id)globalConfigValueFor:(OFString*)key
{
    if (dictGlobalConf == nil) {
        dictGlobalConf = [[OFMutableDictionary alloc] initWithContentsOfFile:@"Config/global_conf.map"];
    }

    return [dictGlobalConf objectForKey:key];
}

+ (OFArray*)extraImports:(OFString*)clazz
{
    if (dictExtraImports == nil) {
        dictExtraImports = [[OFMutableDictionary alloc] initWithContentsOfFile:@"Config/extra_imports.map"];
    }

    return [dictExtraImports objectForKey:clazz];
}

+ (OFDictionary*)extraMethods:(OFString*)clazz
{
    if (dictExtraMethods == nil) {
        dictExtraMethods = [[OFMutableDictionary alloc] initWithContentsOfFile:@"Config/extra_methods.map"];
    }

    return [dictExtraMethods objectForKey:clazz];
}

@end