/*
 * OGTKFileOperation.m
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

#import "OGTKFileOperation.h"
#import "../GIR/GIRInclude.h"

@implementation OGTKFileOperation

+ (void)copyFilesFromDir:(OFString *)sourceDir
                            toDir:(OFString *)destDir
    applyOnFileContentMethodNamed:(OFString *)methodName
                 usingReplaceDict:(OFDictionary *)replaceDict
                  usingRenameDict:(OFDictionary *)renameDict
{
	OFFileManager *fileMgr = [OFFileManager defaultManager];

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
			OFLog(@"File [%@] already exists in destination [%@]. "
			      @"Removing existing file...",
			    srcFile, destFile);

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
			OFLog(@"Applying method [%@] on file [%@] and copying "
			      @"to [%@]...",
			    methodName, srcFile, destFile);

			OFString *fileContents =
			    [OFString stringWithContentsOfFile:srcFile];
			fileContents = [self performSelector:selector
			                          withObject:fileContents
			                          withObject:replaceDict];
			[fileContents writeToFile:destFile];

			// Otherwise just copy
		} else {
			OFLog(
			    @"Copying file [%@] to [%@]...", srcFile, destFile);
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

@end
