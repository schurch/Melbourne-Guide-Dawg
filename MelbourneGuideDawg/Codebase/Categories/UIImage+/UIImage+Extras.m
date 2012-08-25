//
//  UIImage+Extras.m
//  Travel
//
//  Created by Stefan Church on 20/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Extras.h"

@implementation UIImage (Extras)

+ (UIImage *)imageWithImage:(UIImage *)image withRect:(CGRect)rect
{
    CGImageRef cr = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage* cropped = [[[UIImage alloc] initWithCGImage:cr] autorelease];
    CGImageRelease(cr);
    return cropped;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize 
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

+ (CGRect)frameForImage:(UIImage*)image inImageViewAspectFit:(UIImageView*)imageView
{
    float imageRatio = image.size.width / image.size.height;
    float viewRatio = imageView.frame.size.width / imageView.frame.size.height;
    
    if (imageRatio < viewRatio)
    {
        float scale = imageView.frame.size.height / image.size.height;
        float width = scale * image.size.width;
        float topLeftX = (imageView.frame.size.width - width) * 0.5;
        return CGRectMake(topLeftX, 0, width, imageView.frame.size.height);
    }
    else
    {
        float scale = imageView.frame.size.width / image.size.width;
        float height = scale * image.size.height;
        float topLeftY = (imageView.frame.size.height - height) * 0.5;
        return CGRectMake(0, topLeftY, imageView.frame.size.width, height);
    }
}

@end
