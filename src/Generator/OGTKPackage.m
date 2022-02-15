#import "OGTKPackage.h"

@implementation OGTKPackage

OFString *kACArgWithTemplateFile = @"acargwith.tmpl";
OFString *kPkgCheckModulesTemplateFile = @"pkgcheckmodules.tmpl";

+ (OFDictionary *)
    dictWithReplaceValuesForBuildFilesOfLibrary:(OGTKLibrary *)libraryInfo
                        templateSnippetsFromDir:(OFString *)snippetDir
{
	OFString *authorMail;
	if (libraryInfo.authorMail != nil)
		authorMail = libraryInfo.authorMail;
	else
		authorMail = @"unkown@host.com";

	OFString *acArgWith =
	    [self ACSnippetsForDependencies:libraryInfo.dependencies
	            templateSnippetsFromDir:snippetDir];

	OFString *pkgCheckModules =
	    [self ACSnippetForPackage:libraryInfo.packageName
	        templateSnippetFromDir:snippetDir];

    // TODO: %%SOURCESLIST%% is missing

	OFDictionary *dict = [OFDictionary
	    dictionaryWithKeysAndObjects:@"%%LIBNAME%%", libraryInfo.name,
	    @"%%LIBVERSION%%", libraryInfo.version, @"%%LIBAUTHOREMAIL%%",
	    authorMail, @"%%UCLIBNAME%%",
	    [libraryInfo.cNSIdentifierPrefix uppercaseString],
        @"%%LCLIBNAME%%",
	    [libraryInfo.cNSIdentifierPrefix lowercaseString],
	    @"%%VERSIONLIBMAJOR%%", libraryInfo.versionMajor,
	    @"%%VERSIONLIBMINOR%%", libraryInfo.versionMinor, @"%%ACARGWITH%%",
	    acArgWith, @"%%PKGCHECKMODULES%%", pkgCheckModules, nil];

	return dict;
}

+ (OFString *)ACSnippetsForDependencies:(OFMutableSet *)dependencies
                templateSnippetsFromDir:(OFString *)snippetDir
{
	OFMutableString *result = [OFMutableString string];

	for (GIRInclude *library in dependencies) {
		OFString *fileName = [snippetDir
		    stringByAppendingPathComponent:kACArgWithTemplateFile];
		OFMutableString *snippet =
		    [OFMutableString stringWithContentsOfFile:fileName];

		[snippet replaceOccurrencesOfString:@"%%LIBNAME%%"
		                         withString:library.name];

		[snippet
		    replaceOccurrencesOfString:@"%%LCLIBNAME%%"
		                    withString:[library.name lowercaseString]];

		[snippet
		    replaceOccurrencesOfString:@"%%UCLIBNAME%%"
		                    withString:[library.name uppercaseString]];

		[snippet appendString:@"\n\n"];

		[result appendString:snippet];
	}

	[result makeImmutable];

	return result;
}

+ (OFString *)ACSnippetForPackage:(OFString *)package
           templateSnippetFromDir:(OFString *)snippetDir
{
	OFString *fileName = [snippetDir
	    stringByAppendingPathComponent:kPkgCheckModulesTemplateFile];
	OFMutableString *snippet =
	    [OFMutableString stringWithContentsOfFile:fileName];

	OFCharacterSet *charSet = [OFCharacterSet
	    characterSetWithCharactersInString:@"+-_0123456789"];
	size_t index = [package indexOfCharacterFromSet:charSet];

	OFString *shortName;
	if (index != OFNotFound)
		shortName = [package substringToIndex:index];
	else
		shortName = package;

	[snippet replaceOccurrencesOfString:@"%%LCLIBNAME%%"
	                         withString:[shortName lowercaseString]];

	[snippet replaceOccurrencesOfString:@"%%PKGNAME%%" withString:package];

	OFSubprocess *pkgConfigProcess = [OFSubprocess
	    subprocessWithProgram:@"pkg-config"
	                arguments:[OFArray arrayWithObjects:@"--modversion",
	                                   package, nil]];

	OFString *pkgversion = [pkgConfigProcess readLine];
	if (pkgversion == nil)
		@throw [OFReadFailedException
		    exceptionWithObject:pkgConfigProcess
		        requestedLength:[pkgversion length]
		                  errNo:0];

	[snippet replaceOccurrencesOfString:@"%%PKGVERSION%%"
	                         withString:pkgversion];

	[snippet appendString:@"\n\n"];

	[snippet makeImmutable];

	return snippet;
}

@end
