/*
 * GIRFunction.m
 * This file is part of ObjGTK
 *
 * Copyright (C) 2017 - Tyler Burton
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 */

#import "GIRFunction.h"

@implementation GIRFunction

@synthesize name = _name;
@synthesize cIdentifier = _cIdentifier;
@synthesize movedTo = _movedTo;
@synthesize version = _version;
@synthesize introspectable = _introspectable;
@synthesize deprecated = _deprecated;
@synthesize deprecatedVersion = _deprecatedVersion;
@synthesize throws = _throws;
@synthesize docDeprecated = _docDeprecated;
@synthesize doc = _doc;
@synthesize returnValue = _returnValue;
@synthesize parameters = _parameters;
@synthesize instanceParameters = _instanceParameters;

- (id)init
{
	self = [super init];

	@try {
		_elementTypeName = @"GIRFunction";
		_parameters = [[OFMutableArray alloc] init];
		_instanceParameters = [[OFMutableArray alloc] init];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)parseDictionary:(OFDictionary *)dict
{
	for (OFString *key in dict) {
		id value = [dict objectForKey:key];

		if ([key isEqual:@"text"] || [key isEqual:@"source-position"]) {
			// Do nothing
		} else if ([key isEqual:@"name"]) {
			self.name = value;
		} else if ([key isEqual:@"c:identifier"]) {
			self.cIdentifier = value;
		} else if ([key isEqual:@"moved-to"]) {
			self.movedTo = value;
		} else if ([key isEqual:@"version"]) {
			self.version = value;
		} else if ([key isEqual:@"introspectable"]) {
			self.introspectable = [value isEqual:@"1"];
		} else if ([key isEqual:@"deprecated"]) {
			self.deprecated = [value isEqual:@"1"];
		} else if ([key isEqual:@"deprecated-version"]) {
			self.deprecatedVersion = value;
		} else if ([key isEqual:@"throws"]) {
			self.throws = [value isEqual:@"1"];
		} else if ([key isEqual:@"doc-deprecated"]) {
			self.doc = [[[GIRDoc alloc] initWithDictionary:value]
			    autorelease];
		} else if ([key isEqual:@"doc"]) {
			self.doc = [[[GIRDoc alloc] initWithDictionary:value]
			    autorelease];
		} else if ([key isEqual:@"return-value"]) {
			self.returnValue = [[[GIRReturnValue alloc]
			    initWithDictionary:value] autorelease];
		} else if ([key isEqual:@"parameters"]) {
			for (OFString *paramKey in value) {
				if ([paramKey isEqual:@"parameter"]) {
					[self processArrayOrDictionary:
					          [value objectForKey:paramKey]
					                     withClass:
					                         [GIRParameter
					                             class]
					                      andArray:
					                          _parameters];
				} else if ([paramKey
				               isEqual:@"instance-parameter"]) {
					[self
					    processArrayOrDictionary:
					        [value objectForKey:paramKey]
					                   withClass:
					                       [GIRParameter
					                           class]
					                    andArray:
					                        _instanceParameters];
				}
			}
		} else {
			[self logUnknownElement:key];
		}
	}
}

- (void)dealloc
{
	[_name release];
	[_cIdentifier release];
	[_movedTo release];
	[_version release];
	[_deprecatedVersion release];
	[_docDeprecated release];
	[_doc release];
	[_returnValue release];
	[_parameters release];
	[_instanceParameters release];

	[super dealloc];
}

@end
