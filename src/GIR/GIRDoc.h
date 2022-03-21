/*
 * Copyright The ObjGTK authors, see AUTHORS file
 *
 * SPDX-License-Identifier: GPL-3.0+
 */

#import <ObjFW/ObjFW.h>

#import "GIRBase.h"

@interface GIRDoc: GIRBase
{
	OFString *_xmlSpace;
	OFString *_xmlWhitespace;
	OFString *_docText;
}

@property (nonatomic, retain) OFString *xmlSpace;
@property (nonatomic, retain) OFString *xmlWhitespace;
@property (nonatomic, retain) OFString *docText;

@end
