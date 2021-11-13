/*
 * OGTKMethod.m
 * This file is part of ObjGTKGen
 *
 * Copyright (C) 2017 - Tyler Burton
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 */

#import "OGTKMethod.h"
#import "OGTKMapper.h"
#import "OGTKUtil.h"

@implementation OGTKMethod
@synthesize name = _name, cIdentifier = _cIdentifier,
            cReturnType = _cReturnType, parameters = _parameters;

- (void)dealloc
{
    [_name release];
    [_cIdentifier release];
    [_cReturnType release];
    [_parameters release];

    [super dealloc];
}

- (OFString*)name
{
    return [OGTKUtil convertUSSToCamelCase:_name];
}

- (OFString*)sig
{
    // C method with no parameters
    if (_parameters.count == 0) {
        return self.name;
    }
    // C method with only one parameter
    else if (_parameters.count == 1) {
        OGTKParameter* p = [_parameters objectAtIndex:0];

        return
            [OFString stringWithFormat:@"%@:(%@)%@", self.name, p.type, p.name];
    }
    // C method with multiple parameters
    else {
        OFMutableString* output =
            [OFMutableString stringWithFormat:@"%@With", self.name];

        bool first = true;
        for (OGTKParameter* p in _parameters) {
            if (first) {
                first = false;
                [output appendFormat:@"%@:(%@)%@",
                        [OGTKUtil convertUSSToCapCase:p.name], p.type, p.name];
            } else {
                [output appendFormat:@" %@:(%@)%@",
                        [OGTKUtil convertUSSToCamelCase:p.name], p.type,
                        p.name];
            }
        }

        return output;
    }
}

- (OFString*)returnType
{
    return [OGTKMapper swapTypes:_cReturnType];
}

- (bool)returnsVoid
{
    return [_cReturnType isEqual:@"void"];
}

- (void)setParameters:(OFArray*)params
{
    OFMutableArray* mutParams = [[params mutableCopy] autorelease];

    // Hacky fix to get around issue with missing GError parameter from GIR file
    if ([_cIdentifier isEqual:@"gtk_window_set_icon_from_file"] ||
        [_cIdentifier isEqual:@"gtk_window_set_default_icon_from_file"] ||
        [_cIdentifier isEqual:@"gtk_builder_add_from_file"] ||
        [_cIdentifier isEqual:@"gtk_builder_add_from_resource"] ||
        [_cIdentifier isEqual:@"gtk_builder_add_from_string"] ||
        [_cIdentifier isEqual:@"gtk_builder_add_objects_from_file"] ||
        [_cIdentifier isEqual:@"gtk_builder_add_objects_from_resource"] ||
        [_cIdentifier isEqual:@"gtk_builder_add_objects_from_string"] ||
        [_cIdentifier isEqual:@"gtk_builder_extend_with_template"] ||
        [_cIdentifier isEqual:@"gtk_builder_value_from_string"] ||
        [_cIdentifier isEqual:@"gtk_builder_value_from_string_type"] ||
        [_cIdentifier isEqual:@"gtk_css_provider_load_from_data"] ||
        [_cIdentifier isEqual:@"gtk_css_provider_load_from_file"] ||
        [_cIdentifier isEqual:@"gtk_css_provider_load_from_path"] ||
        [_cIdentifier isEqual:@"gtk_icon_info_load_icon"] ||
        [_cIdentifier isEqual:@"gtk_icon_info_load_icon_finish"] ||
        [_cIdentifier isEqual:@"gtk_icon_info_load_symbolic"] ||
        [_cIdentifier isEqual:@"gtk_icon_info_load_symbolic_finish"] ||
        [_cIdentifier isEqual:@"gtk_icon_info_load_symbolic_for_context"] ||
        [_cIdentifier isEqual:@"gtk_icon_info_load_symbolic_for_context_finish"] ||
        [_cIdentifier isEqual:@"gtk_icon_info_load_symbolic_for_style"] ||
        [_cIdentifier isEqual:@"gtk_icon_info_load_surface"] ||
        [_cIdentifier isEqual:@"gtk_icon_theme_load_icon"] ||
        [_cIdentifier isEqual:@"gtk_icon_theme_load_icon_for_scale"] ||
        [_cIdentifier isEqual:@"gtk_icon_theme_load_surface"]) {
        OGTKParameter* param = [[[OGTKParameter alloc] init] autorelease];
        param.cType = @"GError**";
        param.cName = @"err";
        [mutParams addObject:param];
    }

    [_parameters release];
    [mutParams makeImmutable];
    _parameters = [mutParams copy];
}

- (OFArray*)parameters
{
    return [[_parameters copy] autorelease];
}

@end
