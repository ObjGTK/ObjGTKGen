/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import "OFDictionary+OGTKJsonDictionaryOfFile.h"

int _OFDictionary_OGTKJsonDictionaryOfFile_reference;

@implementation OFDictionary (OGTKJsonDictionaryOfFile)

- (instancetype)ogtk_initWithJsonDictionaryOfFile:(OFString *)filePath
{
	id object =
	    [[OFString stringWithContentsOfFile:filePath] objectByParsingJSON];
	if (![object isKindOfClass:[OFDictionary class]])
		@throw [OFInvalidJSONException
		    exceptionWithString:
		        @"JSON file does not contain a dictionary."
		                   line:0];

	self = [self initWithDictionary:object];
	return self;
}

@end