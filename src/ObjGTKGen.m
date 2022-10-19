/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import <ObjFW/ObjFW.h>

#import "Exceptions/OGTKLibraryAlreadyLoadedException.h"
#import "Exceptions/OGTKNamespaceContainsNoClassesException.h"
#import "Exceptions/OGTKNoGIRAPIException.h"
#import "Generator/OGTKClassWriter.h"
#import "Generator/OGTKLibrary.h"
#import "Generator/OGTKLibraryWriter.h"
#import "Generator/OGTKTemplate.h"
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

- (void)loadLibraryDependenciesOf:(OGTKLibrary *)baseLibraryInfo;

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
	[OGTKUtil setDataDir:@DATA_DIR];

	_excludeLibraries = [OGTKUtil globalConfigValueFor:@"excludeLibraries"];
	_sharedMapper = [OGTKMapper sharedMapper];

	OFApplication *app = [OFApplication sharedApplication];
	if (app.arguments.count < 1 ||
	    [(OFString *)app.arguments.firstObject length] == 0) {
		OFLog(@"Missing argument!\n"
		      @"Usage: %@ </path/to/file.gir>\n"
		      @"Linux distributions often store gir files at "
		      @"/usr/share/gir-1.0\n",
		    app.programName);
		[app terminate];
	}

	OFString *outputDir = [OGTKUtil globalConfigValueFor:@"outputDir"];
	OFString *baseClassPath =
	    [OGTKUtil globalConfigValueFor:@"librarySourceAdditionsDir"];

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
			[self loadLibraryDependenciesOf:depLibraryInfo];
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
	[OGTKLibraryWriter writeClassFilesForLibrary:libraryInfo
	                                       toDir:outputDir
	               getClassDefinitionsFromMapper:_sharedMapper];

	// Write and copy additional files to complete the source and headers
	// files for that library
	[OGTKLibraryWriter writeLibraryAdditionsFor:libraryInfo
	                                      toDir:outputDir
	              getClassDefinitionsFromMapper:_sharedMapper
	               readAdditionalSourcesFromDir:baseClassPath];

	// Prepare and copy build files
	OFString *libraryOutputDir =
	    [outputDir stringByAppendingPathComponent:libraryInfo.name];
	OFString *templateDir =
	    [OGTKUtil globalConfigValueFor:@"buildTemplateDir"];
	OFString *templateSnippetsDir = [[OGTKUtil dataDir]
	    stringByAppendingPathComponent:
	        [OGTKUtil globalConfigValueFor:@"templateSnippetsDir"]];

	OFString *sourceFiles = [OGTKLibraryWriter
	        stringForFilesInDir:[libraryOutputDir
	                                stringByAppendingPathComponent:@"src"]
	               addingFormat:@"%@ \\\n\t"
	    lookingForFileExtension:@".m"];

	OGTKTemplate *templating =
	    [[OGTKTemplate alloc] initWithSnippetDir:templateSnippetsDir
	                                sharedMapper:_sharedMapper];
	[templating autorelease];

	OFDictionary *replaceDict = [templating
	    dictWithReplaceValuesForBuildFilesOfLibrary:libraryInfo
	                                    sourceFiles:sourceFiles];

	OFDictionary *renameDict =
	    [templating dictWithRenamesForBuildFilesOfLibrary:libraryInfo];

	[OGTKLibraryWriter copyFilesFromDir:templateDir
	                              toDir:libraryOutputDir
	      applyOnFileContentMethodNamed:@"forFileContent:replaceUsing:"
	                   usingReplaceDict:replaceDict
	                    usingRenameDict:renameDict];
}

@end
