/*
 * CGTKClass.m
 * This file is part of CoreGTKGen
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
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 */

/*
 * Objective-C imports
 */
#import "Generator/CGTKClass.h"

@implementation CGTKClass

-(id)init
{
	self = [super init];

	constructors = [[OFMutableArray alloc] init];
	functions = [[OFMutableArray alloc] init];
	methods = [[OFMutableArray alloc] init];

	return self;
}

-(void)setCName:(OFString *)name
{
	if(cName != nil)
	{
		[cName release];
	}
	
	if(name == nil)
	{
		cName = nil;
	}
	else
	{
		cName = [name retain];
	}
}

-(OFString *)cName
{
	return [[cName retain] autorelease];
}

-(void)setCType:(OFString *)type
{
	if(cType != nil)
	{
		[cType release];
	}
	
	if(type == nil)
	{
		cType = nil;
	}
	else
	{
		cType = [type retain];
	}
}

-(OFString *)cType
{
	return [[cType retain] autorelease];
}

-(OFString *)type
{
	return [CGTKUtil swapTypes:cType];
}

-(void)setCParentType:(OFString *)type
{
	if(cParentType != nil)
	{
		[cParentType release];
	}
	
	if(type == nil)
	{
		cParentType = nil;
	}
	else
	{
		cParentType = [type retain];
	}
}

-(OFString *)cParentType
{
	return [[cParentType retain] autorelease];
}

-(OFString *)name
{
	return [OFString stringWithFormat:@"CGTK%@", cName];
}

-(void)addConstructor:(CGTKMethod *)ctor
{
	if(ctor != nil)
	{
		[constructors addObject:ctor];
	}
}

-(OFArray *)constructors
{
	return constructors;
}

-(bool)hasConstructors
{
	return [constructors count] != 0;
}

-(void)addFunction:(CGTKMethod *)func
{
	if(func != nil)
	{
		[functions addObject:func];
	}
}

-(OFArray *)functions
{
	return functions;
}

-(bool)hasFunctions
{
	return [functions count] != 0;
}

-(void)addMethod:(CGTKMethod *)meth
{
	if(meth != nil)
	{
		[methods addObject:meth];
	}
}

-(OFArray *)methods
{
	return methods;
}

-(bool)hasMethods
{
	return [methods count] != 0;
}

-(void)dealloc
{
	[cName release];
	[cType release];
	[cParentType release];
	[constructors release];
	[functions release];
	[methods release];
	[super dealloc];
}

@end
