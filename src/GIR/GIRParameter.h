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
#import "GIRVarargs.h"

@interface GIRParameter: GIRBase
{
	OFString *_name;
	OFString *_transferOwnership;
	OFString *_direction;
	OFString *_scope;
	bool _allowNone;
	bool _callerAllocates;
	long _closure;
	long _destroy;
	GIRDoc *_doc;
	GIRType *_type;
	GIRArray *_array;
	GIRVarargs *_varargs;
}

@property (nonatomic, retain) OFString *name;
@property (nonatomic, retain) OFString *transferOwnership;
@property (nonatomic, retain) OFString *direction;
@property (nonatomic, retain) OFString *scope;
@property (nonatomic) bool allowNone;
@property (nonatomic) bool callerAllocates;
@property (nonatomic) long closure;
@property (nonatomic) long destroy;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) GIRType *type;
@property (nonatomic, retain) GIRArray *array;
@property (nonatomic, retain) GIRVarargs *varargs;

@end
