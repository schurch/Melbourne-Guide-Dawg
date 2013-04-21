//
//  FullScreenImageViewer.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 17/03/2013.
//
//

#import "FullScreenImageViewer.h"

@interface FullScreenImageViewer()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation FullScreenImageViewer

- (void)displayFullscreenImage:(UIImage *)image
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    //-- Setup image view
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.alpha = 0.0;
    self.imageView.userInteractionEnabled = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //-- Event handling
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImage)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.imageView addGestureRecognizer:tapRecognizer];
    
    //-- If landscape image then rotate 90
    if (image.size.width > image.size.height) {
        image = [[UIImage alloc] initWithCGImage:image.CGImage
                                   scale:1.0
                             orientation:UIImageOrientationRight];
    }
    
    self.imageView.image = image;
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.imageView];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.imageView.alpha = 1.0;
    }];
}

- (void)hideImage
{
    [UIView animateWithDuration:0.25 animations:^ {
        self.imageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.imageView removeFromSuperview];
    }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];    
}

@end
