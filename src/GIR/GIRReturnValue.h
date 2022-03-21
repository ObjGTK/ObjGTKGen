/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

#import "GIRArray.h"
#import "GIRBase.h"
#import "GIRDoc.h"
#import "GIRType.h"

@interface GIRReturnValue: GIRBase
{
	OFString *_transferOwnership;
	GIRDoc *_doc;
	GIRType *_type;
	GIRArray *_array;
}

@property (nonatomic, retain) OFString *transferOwnership;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) GIRType *type;
@property (nonatomic, retain) GIRArray *array;

@end
