//
//  NSString+Numbers.h
//  UTube
//
//  Created by Brent Chionh on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Numbers)

+ (NSString *)commaFormatedStringForNumber:(int)number;
+ (NSString *)timeFormatedStringForSeconds:(int)seconds;

@end