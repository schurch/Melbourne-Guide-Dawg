//
//  UIImage+Creation.m
//  
//
//  Created by Brent Chionh on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Creation.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImage (Creation)

+ (UIImage *)imageWithView:(UIView *)view {
  
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 2.0);
        } 
        else {
            UIGraphicsBeginImageContext(view.bounds.size);
        }
    } 
    else {
        UIGraphicsBeginImageContext(view.bounds.size);
    }    
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

@end