/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "OGTKTemplate.h"
#import "OGTKClass.h"
#import "OGTKMapper.h"

@interface OGTKTemplate ()

+ (OFString *)ACSnippetForIncludes:(OFString *)packageName
           templateSnippetsFromDir:(OFString *)snippetDir;

+ (OFString *)ACSnippetForPackage:(OFString *)packageName
           templateSnippetFromDir:(OFString *)snippetDir;

+ (OFString *)shortNameFromPackageName:(OFString *)packageName;

@end

@implementation OGTKTemplate

OFString *kACArgWithTemplateFile = @"acargwith.tmpl";
OFString *kPkgCheckModulesTemplateFile = @"pkgcheckmodules.tmpl";

+ (OFDictionary *)
    dictWithReplaceValuesForBuildFilesOfLibrary:(OGTKLibrary *)libraryInfo
                        templateSnippetsFromDir:(OFString *)snippetDir
                                    sourceFiles:(OFString *)sourceFiles
{
	OFString *authorMail;
	if (libraryInfo.authorMail != nil)
		authorMail = libraryInfo.authorMail;
	else
		authorMail = @"unkown@host.com";

	OFString *acArgWith = [self ACSnippetForIncludes:libraryInfo.packageName
	                         templateSnippetsFromDir:snippetDir];

	OFString *pkgCheckModules =
	    [self ACSnippetForPackage:libraryInfo.packageName
	        templateSnippetFromDir:snippetDir];

	OFDictionary *dict = [OFDictionary
	    dictionaryWithKeysAndObjects:@"%%LIBNAME%%", libraryInfo.name,
	    @"%%LIBVERSION%%", libraryInfo.version, @"%%LIBAUTHOREMAIL%%",
	    authorMail, @"%%UCLIBNAME%%", [libraryInfo.name uppercaseString],
	    @"%%LCLIBNAME%%", [libraryInfo.name lowercaseString],
	    @"%%VERSIONLIBMAJOR%%", libraryInfo.versionMajor,
	    @"%%VERSIONLIBMINOR%%", libraryInfo.versionMinor, @"%%ACARGWITH%%",
	    acArgWith, @"%%PKGCHECKMODULES%%", pkgCheckModules,
	    @"%%SOURCEFILES%%", sourceFiles, nil];

	return dict;
}

+ (OFDictionary *)dictWithRenamesForBuildFilesOfLibrary:
    (OGTKLibrary *)libraryInfo
{
	OFDictionary *dict = [OFDictionary
	    dictionaryWithKeysAndObjects:@"Template.oc.in",
	    [OFString stringWithFormat:@"%@.oc.in", libraryInfo.name], nil];

	return dict;
}

+ (OFString *)ACSnippetForIncludes:(OFString *)packageName
           templateSnippetsFromDir:(OFString *)snippetDir
{
	OFString *fileName =
	    [snippetDir stringByAppendingPathComponent:kACArgWithTemplateFile];
	OFMutableString *snippet =
	    [OFMutableString stringWithContentsOfFile:fileName];

	OFString *shortName = [self shortNameFromPackageName:packageName];

	[snippet replaceOccurrencesOfString:@"%%LIBNAME%%"
	                         withString:packageName];

	[snippet replaceOccurrencesOfString:@"%%LCLIBNAME%%"
	                         withString:[shortName lowercaseString]];

	[snippet replaceOccurrencesOfString:@"%%UCLIBNAME%%"
	                         withString:[shortName uppercaseString]];

	[snippet appendString:@"\n"];

	[snippet makeImmutable];

	return snippet;
}

+ (OFString *)ACSnippetForPackage:(OFString *)packageName
           templateSnippetFromDir:(OFString *)snippetDir
{
	OFString *fileName = [snippetDir
	    stringByAppendingPathComponent:kPkgCheckModulesTemplateFile];
	OFMutableString *snippet =
	    [OFMutableString stringWithContentsOfFile:fileName];

	OFString *shortName = [self shortNameFromPackageName:packageName];

	[snippet replaceOccurrencesOfString:@"%%LCLIBNAME%%"
	                         withString:[shortName lowercaseString]];

	[snippet replaceOccurrencesOfString:@"%%PKGNAME%%"
	                         withString:packageName];

	OFSubprocess *pkgConfigProcess = [OFSubprocess
	    subprocessWithProgram:@"pkg-config"
	                arguments:[OFArray arrayWithObjects:@"--modversion",
	                                   packageName, nil]];

	OFString *pkgversion = [pkgConfigProcess readLine];
	if (pkgversion == nil)
		@throw [OFReadFailedException
		    exceptionWithObject:pkgConfigProcess
		        requestedLength:[pkgversion length]
		                  errNo:0];

	[snippet replaceOccurrencesOfString:@"%%PKGVERSION%%"
	                         withString:pkgversion];

	[snippet appendString:@"\n"];

	[snippet makeImmutable];

	return snippet;
}

+ (OFString *)shortNameFromPackageName:(OFString *)packageName
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
