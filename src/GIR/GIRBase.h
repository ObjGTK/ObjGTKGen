/*
 * GIRBase.h
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

/**
 * The possible log levels
 */
typedef enum LogLevel {
    Debug = 0,
    Info = 1,
    Warning = 2,
    Error = 3
} LogLevel;

@protocol GIRParseDictionary
- (void)parseDictionary:(OFDictionary*)dict;
- (instancetype)initWithDictionary:(OFDictionary*)dict;
@end

@interface GIRBase : OFObject <GIRParseDictionary> {
    OFString* elementTypeName;
    OFMutableDictionary* unknownElements;
}

@property (nonatomic, copy) OFString* elementTypeName;
@property (nonatomic, retain) OFMutableDictionary* unknownElements;

/**
 * Sets the (current) global log level
 */
+ (void)setLogLevel:(LogLevel)level;

/**
 * Logs the message with the given level
 */
+ (void)log:(OFString*)message andLevel:(LogLevel)level;

/**
 * When an unknown item is discovered this will log it iff it hasn't previously been logged
 */
- (void)logUnknownElement:(OFString*)element;

/**
 * Extracts information from the array or dictionary (values) into the provided array using the provided class type
 */
- (void)processArrayOrDictionary:(id)values withClass:(Class)clazz andArray:(OFMutableArray*)array;

@end
