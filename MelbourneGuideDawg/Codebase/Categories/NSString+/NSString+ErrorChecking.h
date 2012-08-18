//
//  NSString+ErrorChecking.h
//  The Newsgirl
//
//  Created by Brent Chionh on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ErrorChecking)

+ (NSString *)validStringOrNil:(NSString *)string;

@end
