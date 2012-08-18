//
//  NSString+URLEncoding.h
//  imgTumble
//
//  Created by Brent Chionh on 5/7/11.
//  Copyright 2011 rubbleDEV. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSString_URLEncoding)
- (NSString *)URLEncodedString;
- (NSString*)URLDecodedString;
@end
