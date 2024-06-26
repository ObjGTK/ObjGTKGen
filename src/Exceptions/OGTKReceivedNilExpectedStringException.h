/*
 * SPDX-FileCopyrightText: 2021-2023 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2021-2023 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

OF_ASSUME_NONNULL_BEGIN

@interface OGTKReceivedNilExpectedStringException: OFInvalidFormatException
{
	OFString *_parameterName;
}

@property (copy, nonatomic) OFString *parameterName;

- (instancetype)initForParameter:(OFString *)parameterName;
+ (instancetype)exceptionForParameter:(OFString *)parameterName;
- (OFString *)description;

@end

OF_ASSUME_NONNULL_END