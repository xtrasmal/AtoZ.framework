//
//  NSFont+AtoZ.m
//  AtoZ
//
//  Created by Alex Gray on 4/6/13.
//  Copyright (c) 2013 mrgray.com, inc. All rights reserved.
//

#import "NSFont+AtoZ.h"

@implementation NSFont (AtoZ)

- (NSFont *)fontWithSize:(CGFloat)fontSize {

		return [NSFont fontWithName:self.fontName size:fontSize];
}
@end
@implementation NSFont (AMFixes)

- (float)fixed_xHeight
{
	float result = [self xHeight];
	if ([[self familyName] isEqualToString:[[NSFont systemFontOfSize:[NSFont systemFontSize]] familyName]]) {
		switch (lrintf([self pointSize])) {
			case 9: // mini
			{
				result = 5.655762;
				break;
			}
			case 11: // small
			{
				result = 6.912598;
				break;
			}
			case 13: // regular
			{
				result = 8.169434;
				break;
			}
		}
	}
	return result;
}

- (float)fixed_capHeight
{
	float result = [self capHeight];
	if (result == [self ascender]) { // instead of checking for appkit version
		if ([[self familyName] isEqualToString:[[NSFont systemFontOfSize:[NSFont systemFontSize]] familyName]]) { // we do have this info for the system font only 
			switch (lrintf([self pointSize])) {
				case 9: // mini
				{
					result = 7.00;
					break;
				}
				case 11: // small
				{
					result = 8.00;
					break;
				}
				case 13: // regular
				{
					result = 9.50;
					break;
				}
			}
		}
	}
	return result;
}


@end
