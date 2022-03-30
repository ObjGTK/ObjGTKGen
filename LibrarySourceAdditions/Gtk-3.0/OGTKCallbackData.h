/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import <ObjFW/ObjFW.h>

/**
 * Holds object and selector info for gobject signal callbacks
 */
@interface OGTKCallbackData: OFObject
{
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
