/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "GIRBase.h"

@implementation GIRBase

@synthesize elementTypeName = _elementTypeName;
@synthesize unknownElements = _unknownElements;

static LogLevel logLevel = Info;

+ (void)setLogLevel:(LogLevel)level
{
	logLevel = level;
}

+ (void)log:(OFString *)message andLevel:(LogLevel)level
{
	if (level >= logLevel) {
		OFString *levelDescription = nil;

		switch (level) {
		case Debug:
			levelDescription = @"Debug";
			break;
		case Info:
			levelDescription = @"Info";
			break;
		case Warning:
			levelDescription = @"Warning";
			break;
		case Error:
			levelDescription = @"Error";
			break;
		default:
			levelDescription = @"Unkown";
			break;
		}

		OFLog(@"[%@] %@", levelDescription, message);
	}
}

- (void)parseDictionary:(OFDictionary *)dict
{
	OF_UNRECOGNIZED_SELECTOR
}

- (instancetype)initWithDictionary:(OFDictionary *)dict
{
	self = [self init];

	@try {
		[self parseDictionary:dict];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)processArrayOrDictionary:(id)values
                       withClass:(Class)clazz
                        andArray:(OFMutableArray *)array;
{
	// If the values are a dictionary call it directly
	if ([values isKindOfClass:[OFDictionary class]]) {
		id obj = [[[clazz alloc] init] autorelease];

		if ([obj conformsToProtocol:@protocol(GIRParseDictionary)]) {
			[obj parseDictionary:values];
			[array addObject:obj];
		}
	} else if ([values isKindOfClass:[OFArray class]]) {
		for (id object in values) {
			[self processArrayOrDictionary:object
			                     withClass:clazz
			                      andArray:array];
		}
	} else
		@throw [OFInvalidArgumentException exception];
}

- (void)logUnknownElement:(OFString *)element
{
	if (self.unknownElements == nil) {
		self.unknownElements = [OFMutableDictionary dictionary];
	}

	OFString *hopefullyUniqueKey = [OFString
	    stringWithFormat:@"%@--%@", self.elementTypeName, element];

	if ([self.unknownElements objectForKey:hopefullyUniqueKey] != nil) {
		[self.unknownElements setObject:hopefullyUniqueKey
		                         forKey:hopefullyUniqueKey];
	} else {
		[GIRBase log:[OFString stringWithFormat:
		                           @"[%@]: Found unknown element: [%@]",
		                       self.elementTypeName, element]
		    andLevel:Warning];
	}
}

- (void)dealloc
{
	[_elementTypeName release];
	[_unknownElements release];

	[super dealloc];
}

@end
