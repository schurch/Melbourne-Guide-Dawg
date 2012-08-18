//
//  NSString+ErrorChecking.m
//  The Newsgirl
//
//  Created by Brent Chionh on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+ErrorChecking.h"

@implementation NSString (ErrorChecking)

+ (NSString *)validStringOrNil:(NSString *)string {
    if (!string || [string isEqual:[NSNull null]]) {
        return nil;
    }
    if (string.length == 0) {
        return nil;
    }
    return string;
}

@end
