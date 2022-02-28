/*
 * ObjGTKGen.m
 * This file is part of ObjGTKGen
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
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 */

#import <ObjFW/ObjFW.h>

#import "Exceptions/OGTKLibraryAlreadyLoadedException.h"
#import "Exceptions/OGTKNamespaceContainsNoClassesException.h"
#import "Exceptions/OGTKNoGIRAPIException.h"
#import "Generator/OGTKClassWriter.h"
#import "Generator/OGTKFileOperation.h"
#import "Generator/OGTKLibrary.h"
#import "Generator/OGTKPackage.h"
#import "Gir2Objc.h"

@interface ObjGTKGen: OFObject <OFApplicationDelegate>
{

      @private
	OFArray *_excludeLibraries;
	OFString *_girDir;
	OGTKMapper *_sharedMapper;
}

@property (retain, nonatomic) OFArray *excludeLibraries;
@property (copy, nonatomic) OFString *girDir;
@property (retain, nonatomic) OGTKMapper *sharedMapper;

@end

@interface ObjGTKGen ()
- (OGTKLibrary *)loadAPIFromFile:(OFString *)girFile;

- (void)loadDependenciesOf:(OGTKLibrary *)baseLibraryInfo;

- (void)writeAndCopyLibraryFilesFor:(OGTKLibrary *)libraryInfo
                            fromDir:(OFString *)baseClassPath
                              toDir:(OFString *)outputDir;
@end

OF_APPLICATION_DELEGATE(ObjGTKGen)

@implementation ObjGTKGen

@synthesize excludeLibraries = _excludeLibraries, girDir = _girDir,
            sharedMapper = _sharedMapper;

- (void)dealloc
{
	[_excludeLibraries release];
	[_girDir release];
	[_sharedMapper release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching
{
	_excludeLibraries = [OGTKUtil globalConfigValueFor:@"excludeLibraries"];
	_girDir = [OGTKUtil globalConfigValueFor:@"girDir"];
	_sharedMapper = [OGTKMapper sharedMapper];

	OFApplication *app = [OFApplication sharedApplication];
	if (app.arguments.count < 1 ||
	    [(OFString *)app.arguments.firstObject length] == 0) {
		OFLog(@"Missing argument!\n"
		      @"Usage: %@ <girName>\n"
		      @"Directory configured to look for gir files is: %@\n",
		    app.programName, _girDir);
		[app terminate];
	}

	OFString *outputDir = [OGTKUtil globalConfigValueFor:@"outputDir"];
	OFString *baseClassPath =
	    [OGTKUtil globalConfigValueFor:@"librarySourceAdditionsDir"];

	// Load and parse base API from GIR file
	OFString *girFile = [app.arguments firstObject];
	girFile = [_girDir stringByAppendingPathComponent:girFile];

	OGTKLibrary *baseLibraryInfo = [self loadAPIFromFile:girFile];

	[self loadDependenciesOf:baseLibraryInfo];

	// Try to get parent class names for each class
	[_sharedMapper determineParentClassNames];

	// Calculate dependencies for each class
	[_sharedMapper determineDependencies];

	// Set flags for fast necessary forward class definitions.
	[_sharedMapper detectAndMarkCircularDependencies];

	OFMutableDictionary *libraries = _sharedMapper.girNameToLibraryMapping;

	for (OFString *namespace in libraries) {
		OGTKLibrary *library = [libraries objectForKey:namespace];

		[self writeAndCopyLibraryFilesFor:library
		                          fromDir:baseClassPath
		                            toDir:outputDir];
	}

	OFLog(@"%@", @"Process complete");
	[app terminate];
}

- (OGTKLibrary *)loadAPIFromFile:(OFString *)girFile
{
	OFLog(@"Attempting to parse GIR file %@.", girFile);
	GIRAPI *api = [Gir2Objc firstAPIFromGirFile:girFile];

	if (api == nil)
		@throw [OGTKNoGIRAPIException exception];

	OFLog(@"%@", @"Attempting to parse library class information...");
	OGTKLibrary *libraryInfo = [Gir2Objc generateLibraryInfoFromAPI:api];

	// Only load libraries that are not present in memory already
	OGTKLibrary *cachedLibrary =
	    [_sharedMapper libraryInfoByNamespace:libraryInfo.namespace];

	if (cachedLibrary != nil)
		@throw [OGTKLibraryAlreadyLoadedException exception];

	[_sharedMapper addLibrary:libraryInfo];

	@try {
		[Gir2Objc
		    generateClassInfoFromNamespace:api.namespaces.firstObject
		                        forLibrary:libraryInfo
		                        intoMapper:_sharedMapper];
	} @catch (OGTKNamespaceContainsNoClassesException *exception) {
		[_sharedMapper removeLibrary:libraryInfo];
		@throw exception;
	}

	return libraryInfo;
}

/**
 * @brief Load library dependencies recursively.
 */
- (void)loadDependenciesOf:(OGTKLibrary *)baseLibraryInfo
{
	// Load GIR files of depending libraries
	OFMutableSet *dependencies = baseLibraryInfo.dependencies;
	for (GIRInclude *dependency in dependencies) {

		bool continueLoop = false;
		for (OFString *excludeLib in _excludeLibraries) {
			if ([excludeLib isEqual:dependency.name])
				continueLoop = true;
		}
		if (continueLoop)
			continue;

		OFString *depGirFile =
		    [OFString stringWithFormat:@"%@-%@.gir", dependency.name,
		              dependency.version];
		depGirFile =
		    [_girDir stringByAppendingPathComponent:depGirFile];

		OGTKLibrary *depLibraryInfo;
		@try {
			depLibraryInfo = [self loadAPIFromFile:depGirFile];
			[self loadDependenciesOf:depLibraryInfo];
		} @catch (OGTKLibraryAlreadyLoadedException *exception) {
			OFLog(@"Library %@-%@ already loaded.", dependency.name,
			    dependency.version);
		} @catch (OGTKNamespaceContainsNoClassesException *exception) {
			OFLog(@"Library %@-%@ contains no classes. Skipping…",
			    dependency.name, dependency.version);
		}
	}
}

- (void)writeAndCopyLibraryFilesFor:(OGTKLibrary *)libraryInfo
                            fromDir:(OFString *)baseClassPath
                              toDir:(OFString *)outputDir
{
	// Write out classes definition
	[OGTKFileOperation writeClassFilesForLibrary:libraryInfo
	                                       toDir:outputDir
	               getClassDefinitionsFromMapper:_sharedMapper];

	// Write and copy additional files to complete the source and headers
	// files for that library
	[OGTKFileOperation writeLibraryAdditionsFor:libraryInfo
	                                      toDir:outputDir
	              getClassDefinitionsFromMapper:_sharedMapper
	               readAdditionalSourcesFromDir:baseClassPath];

	// Prepare and copy build files
	OFString *libraryOutputDir =
	    [outputDir stringByAppendingPathComponent:libraryInfo.name];
	OFString *templateDir =
	    [OGTKUtil globalConfigValueFor:@"buildTemplateDir"];
	OFString *templateSnippetsDir =
	    [OGTKUtil globalConfigValueFor:@"templateSnippetsDir"];

	OFDictionary *replaceDict = [OGTKPackage
	    dictWithReplaceValuesForBuildFilesOfLibrary:libraryInfo
	                        templateSnippetsFromDir:templateSnippetsDir];

	OFDictionary *renameDict =
	    [OGTKPackage dictWithRenamesForBuildFilesOfLibrary:libraryInfo];

	[OGTKFileOperation copyFilesFromDir:templateDir
	                              toDir:libraryOutputDir
	      applyOnFileContentMethodNamed:@"forFileContent:replaceUsing:"
	                   usingReplaceDict:replaceDict
	                    usingRenameDict:renameDict];
}

@end
