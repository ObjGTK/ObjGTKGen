/*
 * OGTKMapper.m
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

#import "OGTKMapper.h"
#import "OGTKClass.h"
#import "OGTKParameter.h"

static OGTKMapper *sharedMyMapper = nil;

@implementation OGTKMapper

@synthesize gobjTypeToClassMapping = _gobjTypeToClassMapping,
            girNameToClassMapping = _girNameToClassMapping,
            objcTypeToClassMapping = _objcTypeToClassMapping;

#pragma mark - Object lifecycle

- (instancetype)init
{
	self = [super init];

	@try {
		_gobjTypeToClassMapping = [[OFMutableDictionary alloc] init];
		_girNameToClassMapping = [[OFMutableDictionary alloc] init];
		_objcTypeToClassMapping = [[OFMutableDictionary alloc] init];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[_gobjTypeToClassMapping release];
	[_girNameToClassMapping release];
	[_objcTypeToClassMapping release];

	[super dealloc];
}

+ (instancetype)sharedMapper
{
	@synchronized(self) {
		if (sharedMyMapper == nil)
			sharedMyMapper = [[self alloc] init];
	}
	return sharedMyMapper;
}

#pragma mark - Public methods - domain logic

- (void)addClass:(OGTKClass *)classInfo
{
	[_gobjTypeToClassMapping setObject:classInfo forKey:classInfo.cType];

	[_girNameToClassMapping setObject:classInfo forKey:classInfo.cName];

	[_objcTypeToClassMapping setObject:classInfo forKey:classInfo.type];
}

- (void)removeClass:(OGTKClass *)classInfo
{
	if (classInfo.cType != nil &&
	    [_gobjTypeToClassMapping objectForKey:classInfo.cType] != nil)
		[_gobjTypeToClassMapping removeObjectForKey:classInfo.cType];

	if (classInfo.cName != nil &&
	    [_girNameToClassMapping objectForKey:classInfo.cName] != nil)
		[_girNameToClassMapping removeObjectForKey:classInfo.cName];

	if (classInfo.cType != nil && classInfo.type != nil &&
	    [_objcTypeToClassMapping objectForKey:classInfo.type] != nil)
		[_objcTypeToClassMapping removeObjectForKey:classInfo.type];
}

- (bool)isGobjType:(OFString *)type
{
	return ([_gobjTypeToClassMapping
	            objectForKey:[self stripAsterisks:type]] != nil);
}

- (bool)isObjcType:(OFString *)type
{
	return ([_objcTypeToClassMapping
	            objectForKey:[self stripAsterisks:type]] != nil);
}

- (void)determineDependencies
{
	for (OFString *className in _objcTypeToClassMapping) {
		OGTKClass *classInfo =
		    [_objcTypeToClassMapping objectForKey:className];

		if (classInfo.cParentType != nil)
			[classInfo addDependency:classInfo.cParentType];

		for (OGTKMethod *constructor in classInfo.constructors)
			[self addDependenciesFromMethod:constructor
			                             to:classInfo];

		for (OGTKMethod *function in classInfo.functions)
			[self addDependenciesFromMethod:function to:classInfo];

		for (OGTKMethod *method in classInfo.methods)
			[self addDependenciesFromMethod:method to:classInfo];
	}
}

- (void)detectAndMarkCircularDependencies
{
	for (OFString *className in _objcTypeToClassMapping) {
		OGTKClass *classInfo =
		    [_objcTypeToClassMapping objectForKey:className];

		OFMutableDictionary *stack = [[OFMutableDictionary alloc] init];

		[stack setObject:@"1" forKey:classInfo.cType];

		[self walkDependencyTreeFrom:classInfo usingStack:stack];

		[stack release];
	}
}

- (OFString *)swapTypes:(OFString *)type
{
	// Convert basic types by hardcoding
	if ([type isEqual:@"AtkObject"] || [type isEqual:@"GApplication"] ||
	    [type isEqual:@"GInitiallyUnowned"] || [type isEqual:@"GObject"] ||
	    [type isEqual:@"GMountOperation"])
		return @"OGTKObject";
	else if ([type isEqual:@"const gchar*"] || [type isEqual:@"gchar*"])
		return @"OFString*";
	else if ([type isEqual:@"Gtk"])
		return @"OGTK";
	else if ([type isEqual:@"OFString*"])
		return @"const gchar*";

	// Different naming, same type
	else if ([type isEqual:@"gboolean"])
		return @"bool";
	else if ([type isEqual:@"bool"])
		return @"gboolean";

	// Get the number of '*' - currently we only swap simple pointers (*)
	size_t numberOfAsterisks = [self numberOfAsterisksIn:type];
	if (numberOfAsterisks > 1)
		return type;

	OFString *strippedType = [self stripAsterisks:type];

	// Gobj -> ObjC type swapping
	OGTKClass *objcClassInfo =
	    [_gobjTypeToClassMapping objectForKey:strippedType];

	if (objcClassInfo != nil) {
		if ([strippedType isEqual:type])
			return objcClassInfo.type;
		else
			return [OFString
			    stringWithFormat:@"%@*", objcClassInfo.type];
	}

	// ObjC -> Gobj type swapping
	OGTKClass *gobjClassInfo =
	    [_objcTypeToClassMapping objectForKey:strippedType];

	if (gobjClassInfo != nil) {
		if ([strippedType isEqual:type])
			return gobjClassInfo.cType;
		else
			return [OFString
			    stringWithFormat:@"%@*", gobjClassInfo.cType];
	}

	return type;
}

- (bool)isTypeSwappable:(OFString *)type
{
	return [type isEqual:@"gchar*"] || [type isEqual:@"const gchar*"] ||
	    [type isEqual:@"OFString*"] || [type isEqual:@"OFArray*"] ||
	    [self isGobjType:type] || [self isObjcType:type];
}

- (OFString *)convertType:(OFString *)fromType
                 withName:(OFString *)name
                   toType:(OFString *)toType
{
	// Try to return conversion for string types first
	if (([fromType isEqual:@"gchar*"] ||
	        [fromType isEqual:@"const gchar*"]) &&
	    [toType isEqual:@"OFString*"]) {
		return [OFString
		    stringWithFormat:@"[OFString stringWithUTF8String:%@]",
		    name];
	} else if ([fromType isEqual:@"OFString*"] &&
	    ([toType isEqual:@"gchar*"] || [toType isEqual:@"const gchar*"])) {
		return [OFString stringWithFormat:@"[%@ UTF8String]", name];
	}

	// Then try to return generic Gobj type conversion
	if ([self isGobjType:fromType] && [self isObjcType:toType]) {
		// Converting from Gobjc -> Objc

		return
		    [OFString stringWithFormat:
		                  @"[[%@ alloc] initWithGObject:(GObject*)%@]",
		              [self stripAsterisks:toType], name];

	} else if ([self isObjcType:fromType] && [self isGobjType:toType]) {
		// Converting from Objc -> Gobj

		OGTKClass *toClass = [_objcTypeToClassMapping
		    objectForKey:[self stripAsterisks:fromType]];

		return [OFString stringWithFormat:@"[%@ %@]", name,
		                 [toClass.cName uppercaseString]];
	}

	// Otherwise don't do any conversion (including bool types, as ObjFW
	// uses the stdc bool type)
	return name;
}

- (OFString *)selfTypeMethodCall:(OFString *)type;
{
	// Convert OGTKFooBar into [self FOOBAR]
	if ([self isObjcType:type]) {
		OGTKClass *toClass = [_objcTypeToClassMapping
		    objectForKey:[self stripAsterisks:type]];

		return [OFString stringWithFormat:@"[self %@]",
		                 [toClass.cName uppercaseString]];
	}

	// Convert GtkFooBar into GTK_FOO_BAR([self GOBJECT])
	if ([self isGobjType:type]) {
		OGTKClass *classInfo = [_gobjTypeToClassMapping
		    objectForKey:[self stripAsterisks:type]];

		OFString *functionMacroName = [[OFString
		    stringWithFormat:@"%@_%@", classInfo.cNSSymbolPrefix,
		    classInfo.cSymbolPrefix] uppercaseString];

		return [OFString stringWithFormat:@"%@%@", functionMacroName,
		                 @"([self GOBJECT])"];
	}

	return type;
}

- (OFString *)getCTypeFromName:(OFString *)name
{
	// Some shortcut definitions from libraries we do not want to add as
	// dependencies
	if ([name isEqual:@"Atk.Object"])
		return @"AtkObject";
	else if ([name isEqual:@"Gio.Application"])
		return @"GApplication";
	else if ([name isEqual:@"GObject.InitiallyUnowned"])
		return @"GInitiallyUnowned";
	else if ([name isEqual:@"GObject.Object"])
		return @"GObject";

	// Case: Name has a namespace prefix
	if ([name containsString:@"."]) {
		OFArray *nameParts = [name componentsSeparatedByString:@"."];

		OGTKClass *classInfo = [_girNameToClassMapping
		    objectForKey:[nameParts objectAtIndex:1]];

		if (classInfo != nil &&
		    [classInfo.cNSIdentifierPrefix
		        isEqual:[nameParts objectAtIndex:0]])
			return classInfo.cType;
	}

	// Case: Simple name without prefix
	OGTKClass *classInfo = [_girNameToClassMapping objectForKey:name];
	if (classInfo != nil)
		return classInfo.cType;

	// Case: We did not find any c type
	@throw [OFInvalidArgumentException exception];
}

#pragma mark - Private methods - domain logic

- (OFString *)stripAsterisks:(OFString *)identifier
{
	OFCharacterSet *charSet =
	    [OFCharacterSet characterSetWithCharactersInString:@"*"];
	size_t index = [identifier indexOfCharacterFromSet:charSet];

	if (index == OFNotFound)
		return identifier;

	return [identifier substringToIndex:index];
}

- (size_t)numberOfAsterisksIn:(OFString *)identifier
{
	OFCharacterSet *charSet =
	    [OFCharacterSet characterSetWithCharactersInString:@"*"];
	size_t index = [identifier indexOfCharacterFromSet:charSet];

	if (index == OFNotFound)
		return 0;

	return identifier.length - index;
}

- (void)addDependenciesFromMethod:(OGTKMethod *)method to:(OGTKClass *)classInfo
{
	OFString *strippedReturnType = [self stripAsterisks:method.cReturnType];

	if ([self isTypeSwappable:strippedReturnType] &&
	    ![strippedReturnType isEqual:classInfo.cType])
		[classInfo addDependency:strippedReturnType];

	for (OGTKParameter *parameter in method.parameters) {
		OFString *strippedParameterCType =
		    [self stripAsterisks:parameter.cType];

		if ([self isTypeSwappable:strippedParameterCType] &&
		    ![strippedParameterCType isEqual:classInfo.cType])
			[classInfo addDependency:strippedParameterCType];
	}
}

- (void)walkDependencyTreeFrom:(OGTKClass *)classInfo
                    usingStack:(OFMutableDictionary *)stack
{
	if (classInfo.visited) {
		// OFLog(@"Class %@ aleady visited. Skipping…",
		// classInfo.cType);
		return;
	}

	// OFLog(@"Visiting class: %@.", classInfo.cType);
	classInfo.visited = true;

	// First follow parent classes - traverse to the topmost tree element
	OGTKClass *parentClassInfo = nil;

	if (classInfo.cParentType != nil)
		parentClassInfo = [_gobjTypeToClassMapping
		    objectForKey:classInfo.cParentType];

	if (parentClassInfo != nil &&
	    [stack objectForKey:classInfo.cParentType] == nil) {

		[stack setObject:@"1" forKey:classInfo.cParentType];
		[self walkDependencyTreeFrom:parentClassInfo usingStack:stack];
	}

	// OFLog(@"Checking dependencies of %@.", classInfo.cType);
	// Then start to follow dependencies - leave out parent classes this
	// time
	for (OFString *dependencyGobjName in classInfo.dependsOnClasses) {

		// Add a forward declaration if the dependency is within the
		// stack - we're inside a circular dependency structure then
		if ([stack objectForKey:dependencyGobjName] != nil &&
		    ![classInfo.cParentType isEqual:dependencyGobjName]) {

			// OFLog(
			//     @"Detected circular dependency %@, adding forward
			//     declaration.", dependencyGobjName);
			[classInfo
			    addForwardDeclarationForClass:dependencyGobjName];

			continue;
		}

		OGTKClass *dependencyClassInfo =
		    [_gobjTypeToClassMapping objectForKey:dependencyGobjName];

		if (dependencyClassInfo == nil)
			continue;

		// We got a dependency to follow, so we are eady to visit that
		// dependency and follow its dependencies
		[stack setObject:@"1" forKey:dependencyGobjName];

		[self walkDependencyTreeFrom:dependencyClassInfo
		                  usingStack:stack];
	}

	[classInfo removeForwardDeclarationsFromDependencies];
}

#pragma mark - Shortcuts for singleton access

+ (OFString *)swapTypes:(OFString *)type
{
	OGTKMapper *sharedMapper = [OGTKMapper sharedMapper];

	return [sharedMapper swapTypes:type];
}

+ (bool)isTypeSwappable:(OFString *)type
{
	OGTKMapper *sharedMapper = [OGTKMapper sharedMapper];

	return [sharedMapper isTypeSwappable:type];
}

+ (bool)isGobjType:(OFString *)type
{
	OGTKMapper *sharedMapper = [OGTKMapper sharedMapper];

	return [sharedMapper isGobjType:type];
}

+ (bool)isObjcType:(OFString *)type
{
	OGTKMapper *sharedMapper = [OGTKMapper sharedMapper];

	return [sharedMapper isObjcType:type];
}

+ (OFString *)convertType:(OFString *)fromType
                 withName:(OFString *)name
                   toType:(OFString *)toType
{
	OGTKMapper *sharedMapper = [OGTKMapper sharedMapper];

	return [sharedMapper convertType:fromType withName:name toType:toType];
}

+ (OFString *)selfTypeMethodCall:(OFString *)type
{
	OGTKMapper *sharedMapper = [OGTKMapper sharedMapper];

	return [sharedMapper selfTypeMethodCall:type];
}

+ (OFString *)getCTypeFromName:(OFString *)name
{
	OGTKMapper *sharedMapper = [OGTKMapper sharedMapper];

	return [sharedMapper getCTypeFromName:name];
}

@end