/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "OGTKLibraryWriter.h"
#import "../Exceptions/OGTKIncorrectConfigException.h"
#import "../GIR/GIRInclude.h"
#import "OGTKClass.h"
#import "OGTKClassWriter.h"
#import "OGTKLibrary.h"
#import "OGTKMapper.h"

@implementation OGTKLibraryWriter

+ (void)copyFilesFromDir:(OFString *)sourceDir
                            toDir:(OFString *)destDir
    applyOnFileContentMethodNamed:(OFString *)methodName
                 usingReplaceDict:(OFDictionary *)replaceDict
                  usingRenameDict:(OFDictionary *)renameDict
{
	OFFileManager *fileMgr = [OFFileManager defaultManager];

	if (![fileMgr directoryExistsAtPath:sourceDir])
		return;

	OFArray *srcDirContents = [fileMgr contentsOfDirectoryAtPath:sourceDir];

	for (OFString *srcFilePath in srcDirContents) {

		OFString *srcFile = [sourceDir
		    stringByAppendingPathComponent:[srcFilePath
		                                       lastPathComponent]];

		// Rename source file while copying if rename information given
		OFString *destFileName = [srcFilePath lastPathComponent];
		if (renameDict != nil &&
		    [renameDict valueForKey:destFileName] != nil)
			destFileName = [renameDict valueForKey:destFileName];

		OFString *destFile =
		    [destDir stringByAppendingPathComponent:destFileName];

		// src is a directory
		if ([fileMgr directoryExistsAtPath:srcFile]) {
			if (![fileMgr directoryExistsAtPath:destFile])
				[fileMgr createDirectoryAtPath:destFile];

			[self copyFilesFromDir:srcFile
			                            toDir:destFile
			    applyOnFileContentMethodNamed:methodName
			                 usingReplaceDict:replaceDict
			                  usingRenameDict:renameDict];

			continue;
		}

		// else: src is a file
		if ([fileMgr fileExistsAtPath:destFile]) {
			// OFLog(@"File [%@] already exists in destination [%@].
			// "
			//       @"Removing existing file...",
			//     srcFile, destFile);

			@try {
				[fileMgr removeItemAtPath:destFile];
			} @catch (id exception) {
				OFLog(
				    @"Error removing file [%@]. Skipping file.",
				    destFile);
				continue;
			}
		}

		// Apply method on contents of file if method given
		SEL selector;
		if (methodName != nil) {
			selector = sel_registerName([methodName
			    cStringWithEncoding:OFStringEncodingUTF8]);
		}

		if (methodName != nil && replaceDict != nil &&
		    [self respondsToSelector:selector]) {
			// OFLog(@"Applying method [%@] on file [%@] and copying
			// "
			//       @"to [%@]...",
			//     methodName, srcFile, destFile);

			OFString *fileContents =
			    [OFString stringWithContentsOfFile:srcFile];
			fileContents = [self performSelector:selector
			                          withObject:fileContents
			                          withObject:replaceDict];
			[fileContents writeToFile:destFile];

			// Otherwise just copy
		} else {
			// OFLog(
			//     @"Copying file [%@] to [%@]...", srcFile,
			//     destFile);
			[fileMgr copyItemAtPath:srcFile toPath:destFile];
		}
	}
}

+ (void)copyFilesFromDir:(OFString *)sourceDir toDir:(OFString *)destDir
{
	[self copyFilesFromDir:sourceDir
	                            toDir:destDir
	    applyOnFileContentMethodNamed:nil
	                 usingReplaceDict:nil
	                  usingRenameDict:nil];
}

+ (OFString *)forFileContent:(OFString *)content
                replaceUsing:(OFDictionary *)replaceDict
{
	for (OFString *search in replaceDict) {
		content = [content
		    stringByReplacingOccurrencesOfString:search
		                              withString:
		                                  [replaceDict
		                                      valueForKey:search]];
	}

	return content;
}

+ (void)writeClassFilesForLibrary:(OGTKLibrary *)libraryInfo
                            toDir:(OFString *)outputDir
    getClassDefinitionsFromMapper:(OGTKMapper *)mapper
{
	OFMutableDictionary *classesDict = mapper.objcTypeToClassMapping;

	OFString *libraryOutputDir =
	    [[outputDir stringByAppendingPathComponent:libraryInfo.name]
	        stringByAppendingPathComponent:@"src"];

	OFLog(@"Going to generate and write class files for library %@...",
	    libraryInfo.name);

	// Write the classes
	for (OFString *className in classesDict) {
		OGTKClass *classInfo = [classesDict objectForKey:className];
		if ([libraryInfo.namespace isEqual:classInfo.namespace]) {
			[OGTKClassWriter generateFilesForClass:classInfo
			                                 inDir:libraryOutputDir
			                            forLibrary:libraryInfo];
		}
	}
}

+ (void)writeLibraryAdditionsFor:(OGTKLibrary *)libraryInfo
                            toDir:(OFString *)outputDir
    getClassDefinitionsFromMapper:(OGTKMapper *)mapper
     readAdditionalSourcesFromDir:(OFString *)baseClassPath
{
	OFMutableDictionary *classesDict = mapper.objcTypeToClassMapping;

	if (baseClassPath == nil || outputDir == nil)
		@throw [OGTKIncorrectConfigException exception];

	OFString *libraryOutputDir =
	    [[outputDir stringByAppendingPathComponent:libraryInfo.name]
	        stringByAppendingPathComponent:@"src"];

	// Write the umbrella header file for the lib
	[self generateUmbrellaHeaderFileForClasses:classesDict
	                                     inDir:libraryOutputDir
	                                forLibrary:libraryInfo
	              readAdditionalHeadersFromDir:baseClassPath];

	if (!libraryInfo.hasAdditionalSourceFiles)
		return;

	OFLog(
	    @"Going to copy additional source files specific for library %@...",
	    libraryInfo.name);

	[self
	    copyFilesFromDir:[baseClassPath
	                         stringByAppendingPathComponent:libraryInfo
	                                                            .identifier]
	               toDir:libraryOutputDir];
}

+ (void)generateUmbrellaHeaderFileForClasses:
            (OFDictionary OF_GENERIC(OFString *, OGTKClass *) *)objCClassesDict
                                       inDir:(OFString *)outputDir
                                  forLibrary:(OGTKLibrary *)libraryInfo
                readAdditionalHeadersFromDir:(OFString *)additionalHeaderDir
{
	OFString *libName = libraryInfo.name;
	OFMutableString *output = [OFMutableString string];

	OFString *fileName =
	    [OFString stringWithFormat:@"%@-Umbrella.h", libName];
	OFString *license = [OGTKClassWriter generateLicense:fileName];
	[output appendString:license];

	[output appendString:@"\n#import <ObjFW/ObjFW.h>\n\n"];

	if (additionalHeaderDir != nil) {
		@try {
			OFString *headerDir = [additionalHeaderDir
			    stringByAppendingPathComponent:libraryInfo
			                                       .identifier];

			[output
			    appendString:
			        [self stringForFilesInDir:headerDir
			                       addingFormat:@"#import \"%@\"\n"
			            lookingForFileExtension:@".h"]];

		} @catch (OFReadFailedException *e) {
			// Do nothing, set flag to not try to copy anything
			// later
			libraryInfo.hasAdditionalSourceFiles = false;

			// OFLog(@"No additional source files for library %@, "
			//       @"generating header file for generated sources
			//       "
			//       @"only.",
			//     libName);
		}

		[output appendString:@"\n"];
	}

	[output appendString:@"// Generated classes\n"];

	OFArray *sortedKeys = [[objCClassesDict allKeys] sortedArray];

	for (OFString *objCClassName in sortedKeys) {
		OGTKClass *classInfo =
		    [objCClassesDict objectForKey:objCClassName];
		if ([libraryInfo.namespace isEqual:classInfo.namespace])
			[output
			    appendFormat:@"#import \"%@.h\"\n", objCClassName];
	}

	OFString *hFilePath =
	    [outputDir stringByAppendingPathComponent:fileName];

	[output writeToFile:hFilePath];
}

+ (OFString *)stringForFilesInDir:(OFString *)dirPath
                     addingFormat:(OFConstantString *)format
          lookingForFileExtension:(OFString *)fileExtension;
{
	OFMutableString *string = [OFMutableString string];

	OFFileManager *fileMgr = [OFFileManager defaultManager];

	if (![fileMgr directoryExistsAtPath:dirPath]) {
		@throw [OFReadFailedException exceptionWithObject:dirPath
		                                  requestedLength:0
		                                            errNo:0];
	}

	OFArray *srcDirContents = [fileMgr contentsOfDirectoryAtPath:dirPath];
	OFArray *sortedDirContents = [srcDirContents sortedArray];

	for (OFString *srcFile in sortedDirContents) {
		OFString *additionalFile = [srcFile lastPathComponent];
		if ([additionalFile containsString:fileExtension]) {
			[string appendFormat:format, additionalFile];
		}
	}

	[string makeImmutable];
	return string;
}

@end
