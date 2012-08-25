//
//  UIImage+Watermark.h
//  Rated
//
//  Created by Brent Chionh on 4/27/12.
//  Copyright (c) 2012 rubbleDEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Watermark)

- (UIImage *)imageWithWatermark:(UIImage *)watermark andWatermarkFrame:(CGRect)watermarkFrame;

@end
