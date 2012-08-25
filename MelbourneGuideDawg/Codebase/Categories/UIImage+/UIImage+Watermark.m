//
//  UIImage+Watermark.m
//  Rated
//
//  Created by Brent Chionh on 4/27/12.
//  Copyright (c) 2012 rubbleDEV. All rights reserved.
//

#import "UIImage+Watermark.h"

@implementation UIImage (Watermark)

- (UIImage *)imageWithWatermark:(UIImage *)watermark andWatermarkFrame:(CGRect)watermarkFrame {

    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    [self drawAtPoint:CGPointZero];
    [watermark drawInRect:watermarkFrame];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
	// free the context
	UIGraphicsEndImageContext();
    return retImage;
}

@end