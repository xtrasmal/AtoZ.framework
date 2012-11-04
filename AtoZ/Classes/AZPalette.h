//
//  AZPalette.h
//  AtoZ
//
//  Created by Alex Gray on 11/4/12.
//  Copyright (c) 2012 mrgray.com, inc. All rights reserved.
//

#import "AtoZ.h"

@interface AZPalette : NSObject
@property (strong, NATOM) 	NSA *indexed;
@property (strong, NATOM) 	NSMA *feeder;


- (NSC*) nextColor;
- (NSUI) indexOfColor:(NSC*)color;

@end
