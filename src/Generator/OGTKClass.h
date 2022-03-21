/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "OGTKMethod.h"
#import <ObjFW/ObjFW.h>

/**
 * Abstracts Class operations
 */
@interface OGTKClass: OFObject
{
	OFString *_cName;
	OFString *_cType;
	OFString *_namespace;
	OFString *_parentName;
	OFString *_cParentType;
	OFString *_cSymbolPrefix;
	OFString *_cNSSymbolPrefix;
	OFString *_cNSIdentifierPrefix;
	OFString *_documentation;
	OFMutableArray *_constructors;
	OFMutableArray *_functions;
	OFMutableArray *_methods;
	OFMutableSet *_dependsOnClasses;
	OFMutableSet *_forwardDeclarationForClasses;
	bool _visited;
	bool _topMostGraphNode;

      @private
	OFString *_typeWithoutPrefix;
}

@property (copy, nonatomic) OFString *cName;
@property (copy, nonatomic) OFString *cType;
@property (copy, nonatomic) OFString *namespace;
@property (readonly, nonatomic) OFString *type;
@property (copy, nonatomic) OFString *parentName;
@property (copy, nonatomic) OFString *cParentType;
@property (copy, nonatomic) OFString *cSymbolPrefix;
@property (copy, nonatomic) OFString *cNSSymbolPrefix;
@property (copy, nonatomic) OFString *cNSIdentifierPrefix;
@property (copy, nonatomic) OFString *documentation;
@property (readonly, nonatomic) OFArray *constructors;
@property (readonly, nonatomic) bool hasConstructors;
@property (readonly, nonatomic) OFArray *functions;
@property (readonly, nonatomic) bool hasFunctions;
@property (readonly, nonatomic) OFArray *methods;
@property (readonly, nonatomic) bool hasMethods;
@property (readonly, nonatomic) OFMutableSet *dependsOnClasses;
@property (readonly, nonatomic) OFMutableSet *forwardDeclarationForClasses;
@property bool visited;
@property bool topMostGraphNode;

- (void)addConstructor:(OGTKMethod *)ctor;
- (void)addFunction:(OGTKMethod *)fun;
- (void)addMethod:(OGTKMethod *)meth;
- (void)addDependency:(OFString *)cType;
- (void)removeForwardDeclarationsFromDependencies;
- (void)addForwardDeclarationForClass:(OFString *)cType;

@end
