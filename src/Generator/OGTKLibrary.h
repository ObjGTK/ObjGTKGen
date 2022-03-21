/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#import <ObjFW/ObjFW.h>

#import "../GIR/GIRInclude.h"

/**
 * Abstracts Library information
 */
@interface OGTKLibrary: OFObject
{
	OFString *_namespace;
	OFString *_name;
	OFString *_version;
	OFString *_packageName;
	OFString *_authorMail;
	OFMutableSet OF_GENERIC(GIRInclude*) *_dependencies;
	OFMutableSet OF_GENERIC(GIRInclude*) *_cIncludes;
	OFSet *_sharedLibraries;
	OFSet *_excludeClasses;
	OFString *_cNSIdentifierPrefix;
	OFString *_cNSSymbolPrefix;
	bool _visited;
	bool _topmostGraphNode;
}

@property (copy, nonatomic) OFString *namespace;
@property (copy, nonatomic) OFString *name;
@property (copy, nonatomic) OFString *version;
@property (copy, nonatomic) OFString *packageName;
@property (copy, nonatomic) OFString *authorMail;
@property (readonly, nonatomic) OFMutableSet OF_GENERIC(GIRInclude*) *dependencies;
@property (readonly, nonatomic) OFMutableSet OF_GENERIC(GIRInclude*) *cIncludes;
@property (readonly, nonatomic) OFSet *sharedLibraries;
@property (copy, nonatomic) OFSet *excludeClasses;
@property (copy, nonatomic) OFString *cNSIdentifierPrefix;
@property (copy, nonatomic) OFString *cNSSymbolPrefix;
@property (nonatomic) bool visited;

@property (readonly, nonatomic) OFString *identifier;
@property (readonly, nonatomic) OFString *versionMajor;
@property (readonly, nonatomic) OFString *versionMinor;

/**
 * @brief List of shared libraries, separated by comma
 */
- (void)addSharedLibrariesAsString:(OFString *)sharedLibrariesString;
- (void)addDependency:(GIRInclude *)dependency;
- (void)addCInclude:(GIRInclude *)cInclude;

@end
