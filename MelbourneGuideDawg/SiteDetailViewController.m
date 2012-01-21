//
//  SiteDetailViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 18/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SiteDetailViewController.h"
#import "Image.h"
#import "MapViewController.h"

@implementation SiteDetailViewController

@synthesize site = _site;
@synthesize imageButton = _imageButton;
@synthesize titleLabel = _titleLabel;
@synthesize locationLabel = _locationLabel;
@synthesize textLabel = _textLabel;
@synthesize scrollView = _scrollView;
@synthesize viewOnMapButton = _viewOnMapButton;
@synthesize playPauseButton = _playPauseButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([[self.navigationController.viewControllers objectAtIndex:0] isKindOfClass:[MapViewController class]]) 
    {
        self.viewOnMapButton.hidden = YES;
    } else 
    {
        self.viewOnMapButton.hidden = NO;
    }
    
    //load with core data driven file
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"laughter-2" ofType:@"mp3"]];
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
    } else {
        _audioPlayer.delegate = self;
    }
    
    [self.playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    
    self.title = self.site.name;
    self.imageButton.adjustsImageWhenHighlighted = NO;
    Image *image = (Image *)[[self.site.images allObjects] objectAtIndex:0];
    [self.imageButton setImage:[UIImage imageNamed:image.smallFileName]
                 forState:UIControlStateNormal];
    
    self.titleLabel.text = self.site.name;
    self.locationLabel.text = self.site.location;
    self.textLabel.text = self.site.text;
    
    //resize text label to text content size
    CGSize maximumSize = CGSizeMake(self.textLabel.frame.size.width, 9999);
    CGSize textLabelSize = [self.site.text sizeWithFont:self.textLabel.font 
                                   constrainedToSize:maximumSize 
                                       lineBreakMode:self.textLabel.lineBreakMode];
    CGRect textLabelFrame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, textLabelSize.height);
    self.textLabel.frame = textLabelFrame;
    
    int scrollViewHeight = self.imageButton.frame.size.height + self.titleLabel.frame.size.height + self.locationLabel.frame.size.height + self.textLabel.frame.size.height + 30;
    
    self.scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, scrollViewHeight);
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_audioPlayer stop];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _audioPlayer = nil;
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
    [(UIView *)context removeFromSuperview];
}

- (void)hideImage:(id)sender 
{
    [UIView beginAnimations:nil context:sender];
    [UIView setAnimationDuration:0.5];
    [sender setAlpha:0.0];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [UIView commitAnimations];  
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (IBAction)showImage:(id)sender 
{    
    UIButton *largeImage = [UIButton buttonWithType:UIButtonTypeCustom];
    Image *image = (Image *)[[self.site.images allObjects] objectAtIndex:0];
    [largeImage setImage:[UIImage imageNamed:image.imageFileName] forState:UIControlStateNormal];
    largeImage.alpha = 0;
    largeImage.adjustsImageWhenHighlighted = NO;
    [largeImage addTarget:self action:@selector(hideImage:) forControlEvents:UIControlEventTouchUpInside];
    largeImage.transform = CGAffineTransformIdentity;
    largeImage.transform = CGAffineTransformMakeRotation((M_PI * (90) / 180.0));
    largeImage.frame = CGRectMake(0, 0, 320, 480);
    [[[[UIApplication sharedApplication] delegate] window] addSubview:largeImage];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [largeImage setAlpha:1.0];
    [UIView commitAnimations];    
}

- (IBAction)viewMap:(id)sender {
    UINavigationController *mapViewNavigationController = (UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:2];
    [mapViewNavigationController popToRootViewControllerAnimated:NO];
    MapViewController *mapViewController = [mapViewNavigationController.viewControllers objectAtIndex:0];        
    [self.tabBarController setSelectedIndex:2];
    mapViewController.location = CLLocationCoordinate2DMake([self.site.lat doubleValue], [self.site.lng doubleValue]);
    [mapViewController zoomToSite];
}

- (IBAction)playPauseCommentry:(id)sender {
    if (_audioPlayer.isPlaying) {
        [_audioPlayer stop];
        [self.playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    } else {
        [_audioPlayer play];
        [self.playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_site release];
    _site = nil;
    
    [_imageButton release];
    _imageButton = nil;
    
    [_titleLabel release];
    _titleLabel = nil;
    
    [_locationLabel release];
    _locationLabel = nil;
    
    [_textLabel release];
    _textLabel = nil;
    
    [_audioPlayer release];
    _audioPlayer = nil;
    
    [super dealloc];
}

@end
