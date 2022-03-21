/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

/**
 * The possible log levels
 */
typedef enum LogLevel { Debug = 0, Info = 1, Warning = 2, Error = 3 } LogLevel;

@protocol GIRParseDictionary
- (void)parseDictionary:(OFDictionary *)dict;
- (instancetype)initWithDictionary:(OFDictionary *)dict;
@end

@interface GIRBase: OFObject <GIRParseDictionary>
{
	OFString *_elementTypeName;
	OFMutableDictionary *_unknownElements;
}

@property (nonatomic, copy) OFString *elementTypeName;
@property (nonatomic, retain) OFMutableDictionary *unknownElements;

/**
 * Sets the (current) global log level
 */
+ (void)setLogLevel:(LogLevel)level;

/**
 * Logs the message with the given level
 */
+ (void)log:(OFString *)message andLevel:(LogLevel)level;

/**
 * When an unknown item is discovered this will log it iff it hasn't previously
 * been logged
 */
- (void)logUnknownElement:(OFString *)element;

/**
 * Extracts information from the array or dictionary (values) into the provided
 * array using the provided class type
 */
- (void)processArrayOrDictionary:(id)values
                       withClass:(Class)clazz
                        andArray:(OFMutableArray *)array;

@end
