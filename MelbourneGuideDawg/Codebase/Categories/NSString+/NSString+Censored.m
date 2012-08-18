//
//  NSString+Censored.m
//  OzCityWeather
//
//  Created by Brent on 2/1/11.
//  Copyright 2011 rubbleDEV. All rights reserved.
//

#import "NSString+Censored.h"


@implementation NSString(Censored)

+ (NSString *)censoredString:(NSString *)original {

	
	NSString *result = [original stringByReplacingOccurrencesOfString:@"fuck" 
														   withString:@"****" 
															  options:NSCaseInsensitiveSearch 
																range:NSMakeRange(0, [original length])];
	
	result = [result stringByReplacingOccurrencesOfString:@"shit" 
												 withString:@"****" 
													options:NSCaseInsensitiveSearch 
													  range:NSMakeRange(0, [result length])];
	
	result = [result stringByReplacingOccurrencesOfString:@"cunt" 
												 withString:@"****" 
													options:NSCaseInsensitiveSearch 
													  range:NSMakeRange(0, [result length])];
	
	result = [result stringByReplacingOccurrencesOfString:@"bitch" 
												 withString:@"****" 
													options:NSCaseInsensitiveSearch 
													  range:NSMakeRange(0, [result length])];
	
	result = [result stringByReplacingOccurrencesOfString:@"bitch" 
												 withString:@"****" 
													options:NSCaseInsensitiveSearch 
													  range:NSMakeRange(0, [result length])];	
	
	return result;
}

@end