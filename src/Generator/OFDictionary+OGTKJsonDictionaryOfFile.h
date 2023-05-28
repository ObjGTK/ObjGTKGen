/*
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2021-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

extern int _OFDictionary_OGTKJsonDictionaryOfFile_reference;

@interface OFDictionary (OGTKJsonDictionaryOfFile)

/**
 * @brief Tries to initialize an OFDictionary with the dictionary as parsed from
 * a JSON file
 * @param filePath Path to the JSON file to parse
 * @throws OFInvalidJSONException If the JSON file at filePath does not contain
 * a dictionary
 */
- (instancetype)ogtk_initWithJsonDictionaryOfFile:(OFString *)filePath;

@end