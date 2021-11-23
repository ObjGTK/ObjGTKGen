/*
 * OGTKLibrary.m
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

#import "OGTKLibrary.h"
#import "../Exceptions/OGTKReceivedNilExpectedStringException.h"

@implementation OGTKLibrary
@synthesize girName = _girName, name = _name, version = _version,
            packageName = _packageName, authorMail = _authorMail,
            dependencies = _dependencies, cIncludes = _cIncludes,
            sharedLibraries = _sharedLibraries,
            cNSIdentifierPrefix = _cNSIdentifierPrefix,
            cNSSymbolPrefix = _cNSSymbolPrefix, visited = _visited,
            topmostGraphNode = _topmostGraphNode;

- (instancetype)init
{
	self = [super init];

	@try {
		_dependencies = [[OFMutableSet alloc] init];
		_cIncludes = [[OFMutableSet alloc] init];
		_sharedLibraries = [[OFSet alloc] init];
		_visited = false;
		_topmostGraphNode = false;
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[_girName release];
	[_name release];
	[_version release];
	[_packageName release];
	[_authorMail release];
	[_dependencies release];
	[_cIncludes release];
	[_sharedLibraries release];
	[_cNSIdentifierPrefix release];
	[_cNSSymbolPrefix release];

	[super dealloc];
}

- (OFString *)versionMinor
{
	return _version;
}

- (OFString *)versionMajor
{
	return _version;
}

- (void)addSharedLibrariesAsString:(OFString *)sharedLibrariesString
{
	OFSet *sharedLibrariesSet =
	    [OFSet setWithArray:[sharedLibrariesString
	                            componentsSeparatedByString:@","]];

	OFSet *sharedLibrariesResult =
	    [_sharedLibraries setByAddingSet:sharedLibrariesSet];

	[_sharedLibraries release];

	_sharedLibraries = [sharedLibrariesResult retain];
}

- (void)addDependency:(OFString *)dependency
{
	[_dependencies addObject:dependency];
}

- (void)addCInclude:(OFString *)cInclude
{
	[_cIncludes addObject:cInclude];
}

@end
