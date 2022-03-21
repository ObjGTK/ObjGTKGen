/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

#import "GIRBase.h"

@interface GIRAPI: GIRBase
{
	OFString *_version;
	OFString *_package;
	OFMutableArray *_include;
	OFMutableArray *_cInclude;
	OFMutableArray *_namespaces;
}

@property (nonatomic, copy) OFString *version;
@property (nonatomic, copy) OFString *package;
@property (nonatomic, retain) OFMutableArray *include;
@property (nonatomic, retain) OFMutableArray *cInclude;
@property (nonatomic, retain) OFMutableArray *namespaces;

@end