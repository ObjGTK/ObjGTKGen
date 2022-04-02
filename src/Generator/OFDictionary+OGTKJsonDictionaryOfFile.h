/*
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2021-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

extern int _OFDictionary_OGTKJsonDictionaryOfFile_reference;

@interface OFDictionary (OGTKJsonDictionaryOfFile)

- (instancetype)ogtk_initWithJsonDictionaryOfFile:(OFString *)filePath;

@end