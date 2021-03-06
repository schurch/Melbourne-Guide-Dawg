//
//  NSString+URLEncoding.m
//  imgTumble
//
//  Created by Brent Chionh on 5/7/11.
//  Copyright 2011 rubbleDEV. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString (NSString_URLEncoding)

- (NSString *)URLEncodedString 
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8));
	return result;
}

- (NSString*)URLDecodedString
{
	NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
																						   (CFStringRef)self,
																						   CFSTR(""),
																						   kCFStringEncodingUTF8));
	return result;	
}

@end