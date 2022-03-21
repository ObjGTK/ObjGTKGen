/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

#import "GIRBase.h"
#import "GIRDoc.h"
#import "GIRMethodMapping.h"
#import "GIRParameter.h"
#import "GIRReturnValue.h"

@interface GIRFunction: GIRBase <GIRMethodMapping>
{
	OFString *_name;
	OFString *_cIdentifier;
	OFString *_movedTo;
	OFString *_version;
	bool _introspectable;
	bool _deprecated;
	OFString *_deprecatedVersion;
	bool _throws;
	GIRDoc *_docDeprecated;
	GIRDoc *_doc;
	GIRReturnValue *_returnValue;
	OFMutableArray *_parameters;
	OFMutableArray *_instanceParameters;
}

@property (nonatomic, copy) OFString *name;
@property (nonatomic, copy) OFString *cIdentifier;
@property (nonatomic, copy) OFString *movedTo;
@property (nonatomic, copy) OFString *version;
@property (nonatomic) bool introspectable;
@property (nonatomic) bool deprecated;
@property (nonatomic, copy) OFString *deprecatedVersion;
@property (nonatomic) bool throws;
@property (nonatomic, retain) GIRDoc *docDeprecated;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) GIRReturnValue *returnValue;
@property (nonatomic, retain) OFMutableArray *parameters;
@property (nonatomic, retain) OFMutableArray *instanceParameters;

@end
