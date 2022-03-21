/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

OF_ASSUME_NONNULL_BEGIN

@interface OGTKReceivedNilExpectedStringException: OFInvalidFormatException

- (OFString *)description;

@end

OF_ASSUME_NONNULL_END