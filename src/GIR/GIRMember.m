/*
 * GIRMember.m
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
#import "GIRMember.h"

@implementation GIRMember

@synthesize cIdentifier;
@synthesize name;
@synthesize theValue;
@synthesize doc;

-(id)init
{
	self = [super init];
	
	if(self)
	{
		self.elementTypeName = @"GIRMember";
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
			|| [key isEqual:@"glib:nick"])
		{
			// Do nothing
		}	
		else if([key isEqual:@"c:identifier"])
		{
			self.cIdentifier = value;
		}
		else if([key isEqual:@"name"])
		{
			self.name = value;
		}
		else if([key isEqual:@"value"])
		{
			self.theValue = [value intValue];
		}	
		else if([key isEqual:@"doc"])
		{
			self.doc = [[GIRDoc alloc] initWithDictionary:value];
		}	
		else
		{
			[self logUnknownElement:key];
		}
	}	
}

-(void)dealloc
{
	[cIdentifier release];
	[name release];
	[doc release];
	[super dealloc];
}

@end
