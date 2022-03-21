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

@interface GIRMethod: GIRBase <GIRMethodMapping>
{
	OFString *_name;
	OFString *_cIdentifier;
	OFString *_version;
	OFString *_invoker;
	OFString *_glibGetForProperty;
	OFString *_glibSetForProperty;
	GIRReturnValue *_returnValue;
	GIRDoc *_doc;
	GIRDoc *_docDeprecated;
	bool _deprecated;
	OFString *_deprecatedVersion;
	bool _throws;
	bool _introspectable;
	bool _shadowedBy;
	bool _shadows;
	OFMutableArray *_parameters;
	OFMutableArray *_instanceParameters;
}

@property (nonatomic, copy) OFString *name;
@property (nonatomic, copy) OFString *cIdentifier;
@property (nonatomic, copy) OFString *version;
@property (nonatomic, copy) OFString *invoker;
@property (nonatomic, copy) OFString *glibGetForProperty;
@property (nonatomic, copy) OFString *glibSetForProperty;
@property (nonatomic, retain) GIRReturnValue *returnValue;
@property (nonatomic, retain) GIRDoc *doc;
@property (nonatomic, retain) GIRDoc *docDeprecated;
@property (nonatomic, copy) OFString *deprecatedVersion;
@property (nonatomic) bool deprecated;
@property (nonatomic) bool throws;
@property (nonatomic) bool introspectable;
@property (nonatomic) bool shadowedBy;
@property (nonatomic) bool shadows;
@property (nonatomic, retain) OFMutableArray *parameters;
@property (nonatomic, retain) OFMutableArray *instanceParameters;

- (bool)tryParseWithKey:(OFString *)key andValue:(id)value;

@end
