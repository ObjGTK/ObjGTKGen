/*
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2021-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "OGTKTemplate.h"
#import "OGTKClass.h"
#import "OGTKMapper.h"

@interface OGTKTemplate ()

- (OFString *)ACSnippetForObjFWDependencies:(OFMutableSet *)dependencies;

- (OFString *)ACSnippetForIncludes:(OFString *)packageName;

- (OFString *)ACSnippetForPackage:(OFString *)packageName;

- (OFString *)shortNameFromPackageName:(OFString *)packageName;

@end

@implementation OGTKTemplate

@synthesize snippetDir = _snippetDir, sharedMapper = _sharedMapper;

OFString *const kACArgWithTemplateFile = @"acargwith.tmpl";
OFString *const kACOCCheckingTemplateFile = @"acocchecking.tmpl";
OFString *const kPkgCheckModulesTemplateFile = @"pkgcheckmodules.tmpl";

- (instancetype)init
{
	OF_INVALID_INIT_METHOD
}

- (instancetype)initWithSnippetDir:(OFString *)snippetDir
                      sharedMapper:(OGTKMapper *)sharedMapper
{
	self = [super init];

	@try {
		if (snippetDir == nil || sharedMapper == nil)
			@throw [OFInvalidArgumentException exception];

		_snippetDir = [snippetDir copy];
		_sharedMapper = [sharedMapper retain];

	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[_snippetDir release];
	[_sharedMapper release];

	[super dealloc];
}

- (OFDictionary *)
    dictWithReplaceValuesForBuildFilesOfLibrary:(OGTKLibrary *)libraryInfo
                                    sourceFiles:(OFString *)sourceFiles
{
	OFString *authorMail;
	if (libraryInfo.authorMail != nil)
		authorMail = libraryInfo.authorMail;
	else
		authorMail = @"unkown@host.com";

	OFString *acOCChecking =
	    [self ACSnippetForObjFWDependencies:libraryInfo.dependencies];

	OFString *acArgWith =
	    [self ACSnippetForIncludes:libraryInfo.packageName];

	OFString *pkgCheckModules =
	    [self ACSnippetForPackage:libraryInfo.packageName];

	OFDictionary *dict = [OFDictionary
	    dictionaryWithKeysAndObjects:@"%%LIBNAME%%", libraryInfo.name,
	    @"%%LIBVERSION%%", libraryInfo.version, @"%%LIBAUTHOREMAIL%%",
	    authorMail, @"%%UCLIBNAME%%", [libraryInfo.name uppercaseString],
	    @"%%LCLIBNAME%%", [libraryInfo.name lowercaseString],
	    @"%%VERSIONLIBMAJOR%%", libraryInfo.versionMajor,
	    @"%%VERSIONLIBMINOR%%", libraryInfo.versionMinor,
	    @"%%ACOCCHECKING%%", acOCChecking, @"%%ACARGWITH%%", acArgWith,
	    @"%%PKGCHECKMODULES%%", pkgCheckModules, @"%%SOURCEFILES%%",
	    sourceFiles, nil];

	return dict;
}

- (OFDictionary *)dictWithRenamesForBuildFilesOfLibrary:
    (OGTKLibrary *)libraryInfo
{
	OFDictionary *dict = [OFDictionary
	    dictionaryWithKeysAndObjects:@"Template.oc.in",
	    [OFString stringWithFormat:@"%@.oc.in", libraryInfo.name], nil];

	return dict;
}

- (OFString *)ACSnippetForObjFWDependencies:(OFMutableSet OF_GENERIC(
                                                GIRInclude *) *)dependencies
{
	OFString *fileName = [self.snippetDir
	    stringByAppendingPathComponent:kACOCCheckingTemplateFile];
	OFString *snippet = [OFString stringWithContentsOfFile:fileName];

	OFMutableString *result = [OFMutableString string];

	for (GIRInclude *dependency in dependencies) {
		OGTKLibrary *libraryInfo =
		    [self.sharedMapper libraryInfoByNamespace:dependency.name];

		if (libraryInfo == nil)
			continue;

		OFString *libraryName = libraryInfo.name;

		OFString *preparedSnippet =
		    [snippet stringByReplacingOccurrencesOfString:@"%%LIBNAME%%"
		                                       withString:libraryName];

		[result appendString:preparedSnippet];
		[result appendString:@"\n\n"];
	}

	[result deleteEnclosingWhitespaces];
	[result makeImmutable];

	return result;
}

- (OFString *)ACSnippetForIncludes:(OFString *)packageName
{
	OFString *fileName = [self.snippetDir
	    stringByAppendingPathComponent:kACArgWithTemplateFile];
	OFMutableString *snippet =
	    [OFMutableString stringWithContentsOfFile:fileName];

	OFString *shortName = [self shortNameFromPackageName:packageName];

	[snippet replaceOccurrencesOfString:@"%%LIBNAME%%"
	                         withString:packageName];

	[snippet replaceOccurrencesOfString:@"%%LCLIBNAME%%"
	                         withString:[shortName lowercaseString]];

	[snippet replaceOccurrencesOfString:@"%%UCLIBNAME%%"
	                         withString:[shortName uppercaseString]];

	[snippet makeImmutable];

	return snippet;
}

- (OFString *)ACSnippetForPackage:(OFString *)packageName
{
	OFString *fileName = [self.snippetDir
	    stringByAppendingPathComponent:kPkgCheckModulesTemplateFile];
	OFMutableString *snippet =
	    [OFMutableString stringWithContentsOfFile:fileName];

	OFString *shortName = [self shortNameFromPackageName:packageName];

	[snippet replaceOccurrencesOfString:@"%%LCLIBNAME%%"
	                         withString:[shortName lowercaseString]];

	[snippet replaceOccurrencesOfString:@"%%PKGNAME%%"
	                         withString:packageName];

	[snippet
	    replaceOccurrencesOfString:@"%%PKGVERSION%%"
	                    withString:[OFString
	                                   stringWithFormat:
	                                       @"$(pkg-config --modversion %@)",
	                                   packageName]];

	[snippet makeImmutable];

	return snippet;
}

- (OFString *)shortNameFromPackageName:(OFString *)packageName
{
	OFCharacterSet *charSet = [OFCharacterSet
	    characterSetWithCharactersInString:@"+-_0123456789"];
	size_t index = [packageName indexOfCharacterFromSet:charSet];

	OFString *shortName;
	if (index != OFNotFound)
		shortName = [packageName substringToIndex:index];
	else
		shortName = packageName;

	return shortName;
}

@end
