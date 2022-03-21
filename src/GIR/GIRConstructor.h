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

@interface GIRConstructor: GIRBase <GIRMethodMapping>
{
	OFString *_name;
	OFString *_cIdentifier;
	OFString *_version;
	OFString *_deprecatedVersion;
	OFString *_shadowedBy;
	OFString *_shadows;
	bool _introspectable;
	bool _deprecated;
	bool _throws;
	GIRDoc *_doc;
	GIRDoc *_docDeprecated;
	GIRReturnValue *_returnValue;
	OFMutableArray *_parameters;
	OFMutableArray *_instanceParameters;
}

@property (nonatomic, copy) OFString *name;
@property (nonatomic, copy) OFString *cIdentifier;
@property (nonatomic, copy) OFString *version;
@property (nonatomic, copy) OFString *deprecatedVersion;
@property (nonatomic, copy) OFString *shadowedBy;
@property (nonatomic, copy) OFString *shadows;
@property (nonatomic) bool introspectable;
@property (nonatomic) bool deprecated;
@property (nonatomic) bool throws;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) GIRDoc *docDeprecated;
@property (nonatomic, retain) GIRReturnValue *returnValue;
@property (nonatomic, retain) OFMutableArray *parameters;
@property (nonatomic, retain) OFMutableArray *instanceParameters;

@end
