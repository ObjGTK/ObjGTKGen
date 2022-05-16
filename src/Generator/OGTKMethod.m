/*
 * SPDX-FileCopyrightText: 2015-2017 Tyler Burton <software@tylerburton.ca>
 * SPDX-FileCopyrightText: 2021-2022 Johannes Brakensiek <objfw@codingpastor.de>
 * SPDX-FileCopyrightText: 2015-2022 The ObjGTK authors, see AUTHORS file
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#import "OGTKMethod.h"
#import "OGTKMapper.h"
#import "OGTKUtil.h"

@implementation OGTKMethod
@synthesize name = _name, cIdentifier = _cIdentifier,
            cReturnType = _cReturnType, documentation = _documentation,
            returnValueDocumentation = _returnValueDocumentation,
            parameters = _parameters, throws = _throws;

- (instancetype)init
{
	self = [super init];

	_throws = false;

	return self;
}

- (void)dealloc
{
	[_name release];
	[_cIdentifier release];
	[_cReturnType release];
	[_documentation release];
	[_returnValueDocumentation release];
	[_parameters release];

	[super dealloc];
}

- (OFString *)name
{
	return [OGTKUtil convertUSSToCamelCase:_name];
}

- (OFString *)sig
{
	// C method with no parameters
	if (_parameters.count == 0) {
		return self.name;
	}
	// C method with only one parameter
	else if (_parameters.count == 1) {
		OGTKParameter *p = [_parameters objectAtIndex:0];

		return [OFString
		    stringWithFormat:@"%@:(%@)%@", self.name, p.type, p.name];
	}
	// C method with multiple parameters
	else {
		OFMutableString *output =
		    [OFMutableString stringWithFormat:@"%@With", self.name];

		bool first = true;
		for (OGTKParameter *p in _parameters) {
			if (first) {
				first = false;
				[output appendFormat:@"%@:(%@)%@",
				        [OGTKUtil convertUSSToCapCase:p.name],
				        p.type, p.name];
			} else {
				[output appendFormat:@" %@:(%@)%@",
				        [OGTKUtil convertUSSToCamelCase:p.name],
				        p.type, p.name];
			}
		}

		return output;
	}
}

- (OFString *)returnType
{
	return [OGTKMapper swapTypes:_cReturnType];
}

- (bool)returnsVoid
{
	return [_cReturnType isEqual:@"void"];
}

- (void)setParameters:(OFArray *)params
{
	OFMutableArray *mutParams = [[params mutableCopy] autorelease];

	// TODO: Replace this by an OFException implemention within the writer
	if (_throws) {
		OGTKParameter *param =
		    [[[OGTKParameter alloc] init] autorelease];
		param.cType = @"GError**";
		param.cName = @"err";
		[mutParams addObject:param];
	}

	[_parameters release];
	[mutParams makeImmutable];
	_parameters = [mutParams copy];
}

- (OFArray *)parameters
{
	return [[_parameters copy] autorelease];
}

@end
