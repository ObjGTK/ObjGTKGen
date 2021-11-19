/*
 * OGTKUtil.m
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
 */

/*
 * Objective-C imports
 */
#import "OGTKUtil.h"

#import "../Exceptions/OGTKReceivedNilExpectedStringException.h"
#import "OFDictionary+OGTKJsonDictionaryOfFile.h"
#import "OGTKMapper.h"

@implementation OGTKUtil

static OFMutableDictionary *dictGlobalConf;

+ (OFString *)convertUSSToCamelCase:(OFString *)input
{
	OFString *output = [self convertUSSToCapCase:input];

	if ([output length] > 1) {
		return [OFString stringWithFormat:@"%@%@",
		                 [[output substringToIndex:1] lowercaseString],
		                 [output substringFromIndex:1]];
	} else {
		return [output lowercaseString];
	}
}

+ (OFString *)convertUSSToCapCase:(OFString *)input
{
	OFMutableString *output = [[[OFMutableString alloc] init] autorelease];
	OFArray *inputItems = [input componentsSeparatedByString:@"_"];

	bool previousItemWasSingleChar = false;

	for (OFString *item in inputItems) {
		if ([item length] > 1) {
			// Special case where we don't strand single characters
			if (previousItemWasSingleChar) {
				[output appendString:item];
			} else {
				[output
				    appendFormat:@"%@%@",
				    [[item substringToIndex:1] uppercaseString],
				    [item substringFromIndex:1]];
			}
			previousItemWasSingleChar = false;
		} else {
			[output appendString:[item uppercaseString]];
			previousItemWasSingleChar = true;
		}
	}

	return output;
}

+ (OFString *)convertFunctionToInit:(OFString *)func
{
	OFRange range = [func rangeOfString:@"New"];
	if (range.location == OFNotFound) {
		range = [func rangeOfString:@"new"];
	}

	if (range.location == OFNotFound) {
		return nil;
	} else {
		return [OFString stringWithFormat:@"init%@",
		                 [func substringFromIndex:range.location + 3]];
	}
}

+ (OFString *)getFunctionCallForConstructorOfType:(OFString *)cType
                                  withConstructor:(OFString *)cCtor
{
	return [OFString
	    stringWithFormat:@"[super initWithGObject:(GObject*)%@]", cCtor];
}

+ (bool)isUppercase:(OFString *)character
{
	OFUnichar myCharacter = [character characterAtIndex:0];
	if (myCharacter >= 'A' && myCharacter <= 'Z')
		return true;

	return false;
}

+ (id)globalConfigValueFor:(OFString *)key
{
	if (dictGlobalConf == nil) {
		dictGlobalConf = [[OFMutableDictionary alloc]
		    ogtk_initWithJsonDictionaryOfFile:
		        @"Config/global_conf.json"];
	}

	return [dictGlobalConf objectForKey:key];
}

@end