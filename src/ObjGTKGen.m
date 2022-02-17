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

#import "Exceptions/OGTKNoGIRAPIException.h"
#import "Generator/OGTKClassWriter.h"
#import "Generator/OGTKFileOperation.h"
#import "Generator/OGTKLibrary.h"
#import "Generator/OGTKPackage.h"
#import "Gir2Objc.h"

@interface ObjGTKGen: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(ObjGTKGen)

@implementation ObjGTKGen

- (void)applicationDidFinishLaunching
{
	OFString *girDir = [OGTKUtil globalConfigValueFor:@"girDir"];

	OFApplication *app = [OFApplication sharedApplication];
	if (app.arguments.count < 1 || app.arguments.firstObject.length == 0) {
		OFLog(@"Missing argument!\n"
		      @"Usage: %@ <girName>\n"
		      @"Directory configured to look for gir files is: %@\n",
		    app.programName, girDir);
		[app terminate];
	}

	OFString *girFile = [app.arguments firstObject];
	girFile = [girDir stringByAppendingPathComponent:girFile];

	OFLog(@"%@", @"Attempting to parse GIR file...");
	GIRAPI *api = [Gir2Objc firstAPIFromGirFile:girFile];

	if (api == nil)
		@throw [OGTKNoGIRAPIException exception];

	OFLog(@"%@", @"Attempting to generate ObjGTK...");
	OGTKMapper *sharedMapper = [OGTKMapper sharedMapper];
	OFString *outputDir = [OGTKUtil globalConfigValueFor:@"outputDir"];
	OFString *baseClassPath =
	    [OGTKUtil globalConfigValueFor:@"baseClassDir"];

	// Parse library information
	OGTKLibrary *libraryInfo =
	    [Gir2Objc generateLibraryInfoFromAPI:api intoMapper:sharedMapper];

	// Write out classes definition
	[Gir2Objc writeClassFilesForLibrary:libraryInfo
	                              toDir:outputDir
	      getClassDefinitionsFromMapper:sharedMapper];

	// Write and copy additional files to complete the source and headers
	// files for that library
	[Gir2Objc writeLibraryAdditionsFor:libraryInfo
	                             toDir:outputDir
	     getClassDefinitionsFromMapper:sharedMapper
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

	OFLog(@"%@", @"Process complete");

	[app terminate];
}

@end