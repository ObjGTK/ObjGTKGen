/*
 * OGTKCallbackData.h
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
 * Holds object and selector info for gobject signal callbacks
 */
@interface OGTKCallbackData : OFObject {
    id _object;
    SEL _selector;
}

/**
 * The held object.
 */
@property (retain, nonatomic) id object;

/**
 * The held selector.
 */
@property (nonatomic) SEL selector;

/**
 * Creates and returns a new instance of OGTKCallbackData holding the object and
 * the selector.
 *
 * Note this returned instance is autoreleased.
 *
 * @param object
 *  The object to hold
 *
 * @param selector
 *  The selector to hold
 *
 * @returns a new OGTKCallbackData
 */
+ (instancetype)callbackWithObject:(id)object selector:(SEL)selector;

/**
 * Creates and returns a new instance of OGTKCallbackData holding the object and
 * the selector.
 *
 * @param object
 *  The object to hold
 *
 * @param selector
 *  The selector to hold
 *
 * @returns a new OGTKCallbackData
 */
- (instancetype)initWithObject:(id)object selector:(SEL)selector;

@end
