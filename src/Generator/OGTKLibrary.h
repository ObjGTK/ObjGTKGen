/*
 * SPDX-FileCopyrightText: 2021-2024 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2021-2024 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

#import "../GIR/GIRInclude.h"

/**
 * @brief Abstracts Library information
 */
@interface OGTKLibrary: OFObject
{
	OFString *_namespace;
	OFString *_name;
	OFString *_version;
	OFMutableSet OF_GENERIC(OFString *) * _packages;
	OFString *_authorMail;
	OFMutableSet OF_GENERIC(GIRInclude *) * _dependencies;
	OFMutableSet OF_GENERIC(GIRInclude *) * _cIncludes;
	OFSet OF_GENERIC(OFString *) * _sharedLibraries;
	OFSet OF_GENERIC(OFString *) * _excludeClasses;
	OFString *_cNSIdentifierPrefix;
	OFString *_cNSSymbolPrefix;
	bool _visited;
	bool _hasAdditionalSourceFiles;
}

/**
 * @property namespace
 * @brief The name of the namespace, this is the GIR file name attribute of the
 * namespace.
 */
@property (copy, nonatomic) OFString *namespace;

/**
 * @property name
 * @brief  The name of the library. This is the generated or provided name that
 * shall be used for the Objective-C wrapper library.
 */
@property (copy, nonatomic) OFString *name;

/**
 * @property version
 * @brief The version of the library. This is the version of the namespace
 * (like 3.0 for Gtk), it is not the version of the system library/package.
 */
@property (copy, nonatomic) OFString *version;

/**
 * @property packages
 * @brief This is a set of package names for this library to be resolved via pkg-config, f.e.
 * gtk+-3.0 for Gtk 3.0.
 */
@property (retain, nonatomic) OFMutableSet OF_GENERIC(OFString *) * packages;

/**
 * @property authorMail
 * @brief This is the mail address of the author of the library, if noted in
 * in the parsed GIR file.
 */
@property (copy, nonatomic) OFString *authorMail;

/**
 * @property dependencies
 * @brief A set of names of libraries this library depends on.
 * These names are using the naming convention of the GIR file format.
 */
@property (readonly, nonatomic) OFMutableSet OF_GENERIC(GIRInclude *) * dependencies;

/**
 * @property cIncludes
 * @brief A set of strings that are the C include paths of the depending
 * libraries.
 */
@property (readonly, nonatomic) OFMutableSet OF_GENERIC(GIRInclude *) * cIncludes;

/**
 * @property sharedLibraries
 * @brief A set of shared library names that need to be loaded to make the
 * generated source code work.
 */
@property (readonly, nonatomic) OFSet OF_GENERIC(OFString *) * sharedLibraries;

/**
 * @property excludeClasses
 * @brief A set of names of classes that should be omitted when generating the
 * source code for the library.
 */
@property (retain, nonatomic) OFSet OF_GENERIC(OFString *) * excludeClasses;

/**
 * @property cNSIdentifierPrefix
 * @brief The prefix of the library for C identifiers (class names etc.).
 */
@property (copy, nonatomic) OFString *cNSIdentifierPrefix;

/**
 * @property cNSSymbolPrefix
 * @brief The prefix of the library for C symbols (functions names etc.).
 */
@property (copy, nonatomic) OFString *cNSSymbolPrefix;

/**
 * @property visited
 * @brief Flag indicating if the library was already handled while iterating
 * through the tree of dependencies.
 */
@property (nonatomic) bool visited;

/**
 * @property hasAdditionalSourceFiles
 * @brief Flag indicating if the library provides source files written manually
 * to be included by the generated sources.
 *
 * The source files need to be provided in the configured
 * "AdditionalSourceFiles" directory, in a directory named by the namespace name
 * and its version, that is the identifier.
 *
 * @see property identifier
 */
@property (nonatomic) bool hasAdditionalSourceFiles;

/**
 * @property identifier
 * @brief A string constructed in the form of {namespace-version}.
 */
@property (readonly, nonatomic) OFString *identifier;

/**
 * @property versionMajor
 * @brief First part of the version string of the library version.
 */
@property (readonly, nonatomic) OFString *versionMajor;

/**
 * @property versionMinor
 * @brief Second part after first dot of the version string of the library.
 * version
 */
@property (readonly, nonatomic) OFString *versionMinor;

/**
 * @brief Adds a list of shared libraries to the set of shared libraries
 * @param sharedLibrariesString String with list of shared libraries, separated
 * by comma (this usually originates from a GIR file namespace tag).
 */
- (void)addSharedLibrariesAsString:(OFString *)sharedLibrariesString;

/**
 * @brief Adds a GIR name to the set of dependencies
 * @param dependency The name of a library dependency using the GIR format
 * naming convention. This usually originates from a GIR include tag.
 */
- (void)addDependency:(GIRInclude *)dependency;

/**
 * @brief Adds a c header to the set of c headers
 * @param cInclude The c header to include (like "gtk/gtk.h"). This usually
 * originates from a GIR c:include tag
 */
- (void)addCInclude:(GIRInclude *)cInclude;

@end
