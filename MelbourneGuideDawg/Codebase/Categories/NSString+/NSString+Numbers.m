//
//  NSString+Numbers.m
//  UTube
//
//  Created by Brent Chionh on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+Numbers.h"

@implementation NSString (Numbers)

+ (NSString *)commaFormatedStringForNumber:(int)number {
    
    if (number < 1000) {
        return [NSString stringWithFormat:@"%i", number];
    }
    
    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setPositiveFormat:@"#,###"];
    return [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:[NSNumber numberWithInt:number]]];
}


+ (NSString *)timeFormatedStringForSeconds:(int)totalSeconds {
    
    //return 4:23 or 1:33:44 etc
    
    int seconds = totalSeconds % 60; 
    int minutes = (totalSeconds / 60) % 60; 
    int hours = totalSeconds / 3600; 
    
    if (hours <= 0) {
        return [NSString stringWithFormat:@"%d:%02d", minutes, seconds]; 
    }
    return [NSString stringWithFormat:@"%d:%02d:%02d",hours, minutes, seconds]; 
}

@end