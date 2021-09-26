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

/*
 * Objective-C imports
 */
#import "GIRFunction.h"

@implementation GIRFunction

@synthesize name;
@synthesize cIdentifier;
@synthesize movedTo;
@synthesize version;
@synthesize introspectable;
@synthesize deprecated;
@synthesize deprecatedVersion;
@synthesize throws;
@synthesize docDeprecated;
@synthesize doc;
@synthesize returnValue;
@synthesize parameters;
@synthesize instanceParameters;

-(id)init
{
	self = [super init];
	
	if(self)
	{
		self.elementTypeName = @"GIRFunction";
		self.parameters = [[NSMutableArray alloc] init];
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
	
		if([key isEqual:@"text"])
		{
			// Do nothing
		}	
		else if([key isEqual:@"name"])
		{
			self.name = value;
		}	
		else if([key isEqual:@"c:identifier"])
		{
			self.cIdentifier = value;
		}	
		else if([key isEqual:@"moved-to"])
		{
			self.movedTo = value;		
		}
		else if([key isEqual:@"version"])
		{
			self.version = value;		
		}	
		else if([key isEqual:@"introspectable"])
		{
			self.introspectable = [value isEqual:@"1"];		
		}
		else if([key isEqual:@"deprecated"])
		{
			self.deprecated = [value isEqual:@"1"];		
		}
		else if([key isEqual:@"deprecated-version"])
		{
			self.deprecatedVersion = value;		
		}
		else if([key isEqual:@"throws"])
		{
			self.throws = [value isEqual:@"1"];		
		}		
		else if([key isEqual:@"doc-deprecated"])
		{
			self.doc = [[GIRDoc alloc] initWithDictionary:value];
		}
		else if([key isEqual:@"doc"])
		{
			self.doc = [[GIRDoc alloc] initWithDictionary:value];
		}	
		else if([key isEqual:@"return-value"])
		{
			self.returnValue = [[GIRReturnValue alloc] initWithDictionary:value];
		}
		else if([key isEqual:@"parameters"])
		{
			for(NSString *paramKey in value)
			{			
				if([paramKey isEqual:@"parameter"])
				{
					[self processArrayOrDictionary:[value objectForKey:paramKey] withClass:[GIRParameter class] andArray:parameters];
				}
				else if([paramKey isEqual:@"instance-parameter"])
				{
					[self processArrayOrDictionary:[value objectForKey:paramKey] withClass:[GIRParameter class] andArray:instanceParameters];
				}
			}
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
	[cIdentifier release];
	[movedTo release];
	[version release];
	[deprecatedVersion release];
	[docDeprecated release];
	[doc release];
	[returnValue release];
	[parameters release];
	[instanceParameters release];
	[super dealloc];
}

@end
