/*
 * OGTKLibrary.h
 * This file is part of ObjGTKGen
 *
 * Copyright (C) 2021 - Johannes Brakensiek
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 */

#include <ObjFW/OFSet.h>
#import <ObjFW/ObjFW.h>

/**
 * Abstracts Library information
 */
@interface OGTKLibrary: OFObject
{
	OFString *_girName;
	OFString *_name;
	OFString *_version;
	OFString *_packageName;
	OFString *_authorMail;
	OFMutableSet *_dependencies;
	OFMutableSet *_cIncludes;
	OFSet *_sharedLibraries;
	OFSet *_excludeClasses;
	OFString *_cNSIdentifierPrefix;
	OFString *_cNSSymbolPrefix;
	bool _visited;
	bool _topmostGraphNode;
}

@property (copy, nonatomic) OFString *girName;
@property (copy, nonatomic) OFString *name;
@property (copy, nonatomic) OFString *version;
@property (copy, nonatomic) OFString *packageName;
@property (copy, nonatomic) OFString *authorMail;
@property (readonly, nonatomic) OFMutableSet *dependencies;
@property (readonly, nonatomic) OFMutableSet *cIncludes;
@property (readonly, nonatomic) OFSet *sharedLibraries;
@property (copy, nonatomic) OFSet *excludeClasses;
@property (copy, nonatomic) OFString *cNSIdentifierPrefix;
@property (copy, nonatomic) OFString *cNSSymbolPrefix;
@property (nonatomic) bool visited;
@property (nonatomic) bool topmostGraphNode;

@property (readonly, nonatomic) OFString *versionMajor;
@property (readonly, nonatomic) OFString *versionMinor;

/**
 * @brief List of shared libraries, separated by comma
 */
- (void)addSharedLibrariesAsString:(OFString *)sharedLibrariesString;
- (void)addDependency:(OFString *)dependency;
- (void)addCInclude:(OFString *)cInclude;

@end
