/*
 * GIRNamespace.m
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
 
/*
 * Objective-C imports
 */
#import "GIRNamespace.h"

@implementation GIRNamespace

@synthesize name;
@synthesize cSymbolPrefixes;
@synthesize cIdentifierPrefixes;
@synthesize classes;
@synthesize functions;
@synthesize enumerations;
@synthesize constants;
@synthesize interfaces;

-(id)init
{
	self = [super init];
	
	if(self)
	{
		self.elementTypeName = @"GIRNamespace";
		self.classes = [[NSMutableArray alloc] init];
		self.functions = [[NSMutableArray alloc] init];
		self.enumerations = [[NSMutableArray alloc] init];
		self.constants = [[NSMutableArray alloc] init];
		self.interfaces = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithDictionary:(NSDictionary *) dict
{
	self = [self init];
	
	if(self)
	{
		[self parseDictionary:dict];
	}
	
	return self;
}

-(void)parseDictionary:(NSDictionary *) dict
{
	for (NSString *key in dict)
	{	
		id value = [dict objectForKey:key];
	
		if([key isEqual:@"text"]
			|| [key isEqual:@"shared-library"]
			|| [key isEqual:@"version"]
			|| [key isEqual:@"record"]
			|| [key isEqual:@"callback"]
			|| [key isEqual:@"bitfield"]
			|| [key isEqual:@"alias"])
		{
			// Do nothing
		}
		else if([key isEqual:@"name"])
		{
			self.name = value;
		}
		else if([key isEqual:@"c:symbol-prefixes"])
		{
			self.cSymbolPrefixes = value;
		}
		else if([key isEqual:@"c:identifier-prefixes"])
		{
			self.cIdentifierPrefixes = value;
		}		
		else if([key isEqual:@"class"])
		{
			[self processArrayOrDictionary:value withClass:[GIRClass class] andArray:classes];
		}
		else if([key isEqual:@"function"])
		{
			[self processArrayOrDictionary:value withClass:[GIRFunction class] andArray:functions];
		}
		else if([key isEqual:@"enumeration"])
		{
			[self processArrayOrDictionary:value withClass:[GIREnumeration class] andArray:enumerations];
		}
		else if([key isEqual:@"constant"])
		{
			[self processArrayOrDictionary:value withClass:[GIRConstant class] andArray:constants];
		}
		else if([key isEqual:@"interface"])
		{
			[self processArrayOrDictionary:value withClass:[GIRInterface class] andArray:interfaces];
		}
		else
		{
			[self logUnknownElement:key];
		}
	}	
}

-(void)dealloc
{
	[name release];
	[cSymbolPrefixes release];
	[cIdentifierPrefixes release];
	[classes release];
	[functions release];
	[enumerations release];
	[constants release];
	[interfaces release];
	[super dealloc];
}

@end
