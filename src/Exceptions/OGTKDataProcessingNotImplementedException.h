/*
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2021-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

OF_ASSUME_NONNULL_BEGIN

@interface OGTKDataProcessingNotImplementedException: OFException
{
	OFString *_description;
}

@property (readonly, nonatomic) OFString *description;

+ (instancetype)exception OF_UNAVAILABLE;
+ (instancetype)exceptionWithDescription:(OFString *)description;
- (instancetype)init OF_UNAVAILABLE;
- (instancetype)initWithDescription:(OFString *)description;

@end

OF_ASSUME_NONNULL_END
