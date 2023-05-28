/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import <ObjFW/ObjFW.h>

#import "OGTKMapper.h"

/**
 * @brief Abstracts Parameter operations
 */
@interface OGTKParameter: OFObject
{
	OFString *_cType;
	OFString *_cName;
	OFString *_documentation;
}

@property (copy, nonatomic) OFString *cType;
@property (readonly, nonatomic) OFString *type;
@property (copy, nonatomic) OFString *cName;
@property (readonly, nonatomic) OFString *name;
@property (copy, nonatomic) OFString *documentation;

@end
