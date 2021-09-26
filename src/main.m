/*
 * main.h
 * This file is part of CoreGTKGen
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
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

/*
 * Modified by the ObjGTK Team, 2021. See the AUTHORS file for a
 * list of people on the ObjGTK Team.
 * See the ChangeLog files for a list of changes.
 */

#import <ObjFW/ObjFW.h>

#import "Exceptions/OGTKIncorrectConfigException.h"
#import "Exceptions/OGTKNoGIRAPIException.h"
#import "Generator/CGTKClassWriter.h"
#import "Gir2Objc.h"

int main(int argc, char* argv[])
{
    // Step 1: parse GIR file

    OFString* girFile = [CGTKUtil globalConfigValueFor:@"girFile"];

    OFLog(@"%s", @"Attempting to parse GIR file...");
    GIRApi* api = [Gir2Objc firstApiFromGirFile:girFile];

    if (api == nil)
        @throw [OGTKNoGIRAPIException exception]];

    // Step 2: generate CoreGTK source files
    OFLog(@"%s", @"Attempting to generate CoreGTK...");
    [Gir2Objc generateClassFilesFromApi:api];
    OFLog(@"%s", @"Process complete");

    // Step 3: copy CoreGTK base files
    OFString* baseClassPath = [CGTKUtil globalConfigValueFor:@"baseClassDir"];
    OFString* outputDir = [CGTKUtil globalConfigValueFor:@"outputDir"];

    if (baseClassPath == nil || outputDir == nil)
        @throw [OGTKIncorrectConfigException exception];

    OFLog(@"%s", @"Attempting to copy CoreGTK base class files...");
    OFFileManager* fileMgr = [OFFileManager defaultManager];

    OFArray* srcDirContents = [fileMgr contentsOfDirectoryAtPath:baseClassPath];

    for (OFString* srcFile in srcDirContents) {
        OFString* src = [baseClassPath stringByAppendingPathComponent:[srcFile lastPathComponent]];
        OFString* dest = [outputDir stringByAppendingPathComponent:
                                        [srcFile lastPathComponent]];

        if ([fileMgr fileExistsAtPath:dest]) {
            OFLog(@"File [%@] already exists in destination [%@]. Removing existing file...", src, dest);
            if (![fileMgr removeItemAtPath:dest]) {
                OFLog(@"Error removing file [%@]. Skipping file.", dest);
                continue;
            }
        }

        OFLog(@"Copying file [%@] to [%@]...", src, dest);
        [fileMgr copyItemAtPath:src toPath:dest];
    }

    OFLog(@"%s", @"Process complete");

    // Release memory
    [baseClassPath release];
    [outputDir release];

    // Return success
    return 0;
}
