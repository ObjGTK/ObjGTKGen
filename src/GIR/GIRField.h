/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

#import "GIRArray.h"
#import "GIRBase.h"
#import "GIRType.h"

@interface GIRField: GIRBase
{
	OFString *_name;
	bool _isPrivate;
	bool _readable;
	int _bits;
	GIRType *_type;
	GIRArray *_array;
}

@property (nonatomic, retain) OFString *name;
@property (nonatomic) bool isPrivate;
@property (nonatomic) bool readable;
@property (nonatomic) int bits;
@property (nonatomic, retain) GIRType *type;
@property (nonatomic, retain) GIRArray *array;

@end
