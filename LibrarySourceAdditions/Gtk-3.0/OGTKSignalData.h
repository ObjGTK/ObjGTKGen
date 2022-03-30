/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import <ObjFW/ObjFW.h>

/**
 * Wraps GCallback signal data
 */
@interface OGTKSignalData: OFObject
{
	id _target;
	SEL _selector;
	void *_data;
	bool _retained;
}

@property (readonly, nonatomic) id target;
@property (readonly) SEL selector;
@property (readonly) void *data;
@property (readonly, getter=isDataRetained) bool dataRetained;

- (instancetype)initWithTarget:(id)target
                      selector:(SEL)selector
                          data:(void *)data;

@end
