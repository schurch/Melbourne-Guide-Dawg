//
//  UIImage+Scaling.h
//  Tumblaze
//
//  Created by Brent Chionh on 4/27/11.
//  Copyright 2011 rubbleDEV. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (UIImage_Scaling)
- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithBorderFromImage:(UIImage *)source;
@end
