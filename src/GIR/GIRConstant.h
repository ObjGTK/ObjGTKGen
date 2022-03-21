/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

#import "GIRBase.h"
#import "GIRDoc.h"
#import "GIRType.h"

@interface GIRConstant: GIRBase
{
	OFString *_cType;
	OFString *_name;
	OFString *_theValue;
	OFString *_version;
	OFString *_deprecatedVersion;
	bool _deprecated;
	GIRDoc *_doc;
	GIRDoc *_docDeprecated;
	GIRType *_type;
}

@property (nonatomic, retain) OFString *cType;
@property (nonatomic, retain) OFString *name;
@property (nonatomic, retain) OFString *theValue;
@property (nonatomic, retain) OFString *version;
@property (nonatomic, retain) OFString *deprecatedVersion;
@property (nonatomic) bool deprecated;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) GIRDoc *docDeprecated;
@property (nonatomic, retain) GIRType *type;

@end
