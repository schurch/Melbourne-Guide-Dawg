//
//  UIUnderlineButton.m
//  Travel
//
//  Created by Stefan Church on 15/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIUnderlineButton.h"

@implementation UIUnderlineButton

+ (UIUnderlineButton *) underlinedButton {
    
    UIUnderlineButton* button = [[UIUnderlineButton alloc] init];
    return button;
}

- (void)drawRect:(CGRect)rect {
    
    CGRect textRect = self.titleLabel.frame;
    
    // need to put the line at top of descenders (negative value)
    CGFloat descender = 0.5;
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // set to same colour as text
    CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender);
    CGContextClosePath(contextRef);
    CGContextDrawPath(contextRef, kCGPathStroke);
}


@end
