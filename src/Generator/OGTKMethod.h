/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "OGTKParameter.h"
#import <ObjFW/ObjFW.h>

/**
 * Abstracts Method operations
 */
@interface OGTKMethod: OFObject
{
	OFString *_name;
	OFString *_cIdentifier;
	OFString *_cReturnType;
	OFString *_documentation;
	OFString *_returnValueDocumentation;
	OFArray *_parameters;
	bool _throws;
}

@property (copy, nonatomic) OFString *name;
@property (copy, nonatomic) OFString *cIdentifier;
@property (copy, nonatomic) OFString *documentation;
@property (copy, nonatomic) OFString *returnValueDocumentation;
@property (readonly, nonatomic) OFString *sig;
@property (copy, nonatomic) OFString *cReturnType;
@property (readonly, nonatomic) OFString *returnType;
@property (readonly, nonatomic) bool returnsVoid;
@property (copy, nonatomic) OFArray *parameters;
@property (nonatomic) bool throws;

@end
