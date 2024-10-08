/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import <ObjFW/ObjFW.h>

#import "Exceptions/OGTKNamespaceContainsNoClassesException.h"
#import "Exceptions/OGTKNoGIRAPIException.h"
#import "Generator/OGTKClassWriter.h"
#import "Generator/OGTKLibrary.h"
#import "Generator/OGTKLibraryWriter.h"
#import "Gir2Objc.h"

@interface Gir2ObjcApplication: OFObject <OFApplicationDelegate>
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

@interface Gir2ObjcApplication ()
- (OGTKLibrary *)loadAPIFromFile:(OFString *)girFile;

- (void)loadLibraryDependenciesOf:(OGTKLibrary *)baseLibraryInfo;

- (void)writeAndCopyLibraryFilesFor:(OGTKLibrary *)libraryInfo
                            fromDir:(OFString *)baseClassPath
                              toDir:(OFString *)outputDir;
@end

OF_APPLICATION_DELEGATE(Gir2ObjcApplication)

@implementation Gir2ObjcApplication

@synthesize excludeLibraries = _excludeLibraries, girDir = _girDir, sharedMapper = _sharedMapper;

- (void)dealloc
{
	[_excludeLibraries release];
	[_girDir release];
	[_sharedMapper release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(OFNotification *)notification
{
	[OGTKUtil setDataDir:@DATA_DIR];

	_excludeLibraries = [OGTKUtil globalConfigValueFor:@"excludeLibraries"];
	_sharedMapper = [OGTKMapper sharedMapper];

	OFApplication *app = [OFApplication sharedApplication];
	if (app.arguments.count < 1 || [(OFString *)app.arguments.firstObject length] == 0) {
		OFLog(@"Missing argument!\n"
		      @"Usage: %@ </path/to/file.gir>\n"
		      @"Linux distributions often store gir files at "
		      @"/usr/share/gir-1.0\n",
		    app.programName);
		[app terminate];
	}

	OFString *outputDir = [OGTKUtil globalConfigValueFor:@"outputDir"];
	OFString *baseClassPath = [OGTKUtil globalConfigValueFor:@"librarySourceAdditionsDir"];

	// Load and parse base API from GIR file
	OFString *girFile = [app.arguments firstObject];
	_girDir = [girFile stringByDeletingLastPathComponent];

	OGTKLibrary *baseLibraryInfo = [self loadAPIFromFile:girFile];

	[self loadLibraryDependenciesOf:baseLibraryInfo];

	// Try to get parent class names for each class
	[_sharedMapper determineParentClassNames];

	// Calculate dependencies for each class
	[_sharedMapper determineClassDependencies];

	// Set flags for fast necessary forward class definitions.
	[_sharedMapper detectAndMarkCircularClassDependencies];

	OFMutableDictionary *libraries = _sharedMapper.girNameToLibraryMapping;

	for (OFString *namespace in libraries) {
		OGTKLibrary *library = [libraries objectForKey:namespace];

		[self writeAndCopyLibraryFilesFor:library fromDir:baseClassPath toDir:outputDir];
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
	[_sharedMapper addLibrary:libraryInfo];

	@try {
		[Gir2Objc generateClassInfoFromNamespace:api.namespaces.firstObject
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
- (void)loadLibraryDependenciesOf:(OGTKLibrary *)baseLibraryInfo
{
	// Load GIR files of depending libraries
	OFMutableSet *dependencies = baseLibraryInfo.dependencies;
	for (GIRInclude *dependency in dependencies) {

		bool continueLoop = false;
		for (OFString *excludeLib in _excludeLibraries) {
			if ([excludeLib isEqual:dependency.name])
				continueLoop = true;
		}

		// Only load libraries that are not present in memory already
		OGTKLibrary *cachedLibrary = [_sharedMapper libraryInfoByNamespace:dependency.name];

		if (cachedLibrary != nil) {
			OFLog(
			    @"Library %@-%@ already loaded.", dependency.name, dependency.version);
			continueLoop = true;
		}

		if (continueLoop)
			continue;

		OFString *depGirFile =
		    [OFString stringWithFormat:@"%@-%@.gir", dependency.name, dependency.version];
		depGirFile = [_girDir stringByAppendingPathComponent:depGirFile];

		OGTKLibrary *depLibraryInfo;
		@try {
			depLibraryInfo = [self loadAPIFromFile:depGirFile];
			[self loadLibraryDependenciesOf:depLibraryInfo];
		} @catch (OGTKNamespaceContainsNoClassesException *exception) {
			OFLog(@"Library %@-%@ contains no classes. Skipping…", dependency.name,
			    dependency.version);
		}
	}
}

- (void)writeAndCopyLibraryFilesFor:(OGTKLibrary *)libraryInfo
                            fromDir:(OFString *)baseClassPath
                              toDir:(OFString *)outputDir
{
	OFString *libraryOutputDir = [outputDir stringByAppendingPathComponent:libraryInfo.name];

	OGTKLibraryWriter *libraryWriter =
	    [[OGTKLibraryWriter alloc] initWithLibrary:libraryInfo
	                                        mapper:_sharedMapper
	                                     outputDir:libraryOutputDir];

	// Write out classes definitions
	[libraryWriter writeClassFiles];

	// Write and copy additional files to complete the source and headers
	// files for that library
	[libraryWriter writeLibraryAdditionsWithSourcesFromDir:baseClassPath];

	// Prepare and copy build files
	OFString *templateDir = [OGTKUtil globalConfigValueFor:@"buildTemplateDir"];
	OFString *templateSnippetsDir = [[OGTKUtil dataDir]
	    stringByAppendingPathComponent:[OGTKUtil globalConfigValueFor:@"templateSnippetsDir"]];

	[libraryWriter templateAndCopyBuildFilesFromDir:templateDir
	                           usingSnippetsFromDir:templateSnippetsDir];

	[libraryWriter release];
}

@end
