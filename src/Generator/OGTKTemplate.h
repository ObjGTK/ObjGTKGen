/*
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2021-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "OGTKLibrary.h"
#import <ObjFW/ObjFW.h>
@class OGTKMapper;

@interface OGTKTemplate: OFObject
{
	OFString *_snippetDir;
	OGTKMapper *_sharedMapper;
}

@property (copy, nonatomic) OFString *snippetDir;
@property (retain, nonatomic) OGTKMapper *sharedMapper;

- (instancetype) init OF_UNAVAILABLE;

- (instancetype)initWithSnippetDir:(OFString *)snippetDir
                      sharedMapper:(OGTKMapper *)sharedMapper;

- (OFDictionary *)
    dictWithReplaceValuesForBuildFilesOfLibrary:(OGTKLibrary *)libraryInfo
                                    sourceFiles:(OFString *)sourceFiles;

- (OFDictionary *)dictWithRenamesForBuildFilesOfLibrary:
    (OGTKLibrary *)libraryInfo;

@end