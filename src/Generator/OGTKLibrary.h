/*
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2021-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
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
	bool _hasAdditionalSourceFiles;
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
@property (nonatomic) bool hasAdditionalSourceFiles;

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
