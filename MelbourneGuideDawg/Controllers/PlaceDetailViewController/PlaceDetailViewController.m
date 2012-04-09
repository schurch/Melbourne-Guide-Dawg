//
//  SiteDetailViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 18/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceDetailViewController.h"
#import "MapViewController.h"

@implementation PlaceDetailViewController

@synthesize place = _place;
@synthesize imageButton = _imageButton;
@synthesize titleLabel = _titleLabel;
@synthesize locationLabel = _locationLabel;
@synthesize textLabel = _textLabel;
@synthesize scrollView = _scrollView;
@synthesize viewOnMapButton = _viewOnMapButton;
@synthesize playPauseButton = _playPauseButton;
@synthesize detailActionsView = _detailActionsView;
@synthesize viewWebsiteButton = _viewWebsiteButton;

#pragma mark - Init -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {

    }
    return self;
}

#pragma mark - Memory management -

- (void)dealloc 
{
    [_place release];
    [_imageButton release];
    [_titleLabel release];
    [_locationLabel release];
    [_textLabel release];
    [_audioPlayer release];
    [_detailActionsView release];
    [_viewWebsiteButton release];
    
    [super dealloc];
}

#pragma mark - View lifecycle -

- (void)viewWillAppear:(BOOL)animated 
{
    
    [super viewWillAppear:animated];
    
    if ([[self.navigationController.viewControllers objectAtIndex:0] isKindOfClass:[MapViewController class]]) 
    {
        self.viewOnMapButton.hidden = YES;
        self.detailActionsView.hidden = YES;
    } 
    else 
    {
        self.viewOnMapButton.hidden = NO;
        self.detailActionsView.hidden = NO;
    }
    
    //load with core data driven file
//    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"laughter-2" ofType:@"mp3"]];
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:nil error:&error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
    } else {
        _audioPlayer.delegate = self;
    }
    
    [self.playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    
    self.title = self.place.name;
    self.imageButton.adjustsImageWhenHighlighted = NO;
//    Image *image = (Image *)[[self.place.images allObjects] objectAtIndex:0];
//    [self.imageButton setImage:[UIImage imageNamed:image.smallFileName]
//                 forState:UIControlStateNormal];
    
    self.titleLabel.text = self.place.name;
    self.locationLabel.text = self.place.address;
    self.textLabel.text = self.place.text;
    
    //resize text label to text content size
    CGSize maximumSize = CGSizeMake(self.textLabel.frame.size.width, 9999);
    CGSize textLabelSize = [self.place.text sizeWithFont:self.textLabel.font 
                                   constrainedToSize:maximumSize 
                                       lineBreakMode:self.textLabel.lineBreakMode];
    CGRect textLabelFrame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, textLabelSize.height);
    self.textLabel.frame = textLabelFrame;
    
    int scrollViewHeight = self.imageButton.frame.size.height + self.titleLabel.frame.size.height + self.locationLabel.frame.size.height + self.textLabel.frame.size.height + 30;
    
    if (self.place.url) {
        [self.viewWebsiteButton setTitle:self.place.url forState:UIControlStateNormal];
        self.viewWebsiteButton.hidden = NO;
        self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 286, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
        scrollViewHeight += 20;
    } else {
        self.viewWebsiteButton.hidden = YES;
        self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 265, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    }
    
    self.scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, scrollViewHeight);
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    [_audioPlayer stop];
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

# pragma mark - UI actions - 

- (IBAction)showImage:(id)sender 
{    
    UIButton *largeImage = [UIButton buttonWithType:UIButtonTypeCustom];
//    Image *image = (Image *)[[self.place.images allObjects] objectAtIndex:0];
//    [largeImage setImage:[UIImage imageNamed:image.imageFileName] forState:UIControlStateNormal];
    largeImage.alpha = 0;
    largeImage.adjustsImageWhenHighlighted = NO;
    [largeImage addTarget:self action:@selector(hideImage:) forControlEvents:UIControlEventTouchUpInside];
    largeImage.transform = CGAffineTransformIdentity;
    largeImage.transform = CGAffineTransformMakeRotation((M_PI * (90) / 180.0));
    largeImage.frame = CGRectMake(0, 0, 320, 480);
    [[[[UIApplication sharedApplication] delegate] window] addSubview:largeImage];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.5 animations:^
    {
        largeImage.alpha = 1.0;
    }];
}

- (IBAction)visitWebSite:(id)sender
{
    NSLog(@"Visit URL at: %@", self.place.url);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.place.url]];
}

- (IBAction)viewMap:(id)sender 
{
    UINavigationController *mapViewNavigationController = (UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:2];
    [mapViewNavigationController popToRootViewControllerAnimated:NO];
    MapViewController *mapViewController = [mapViewNavigationController.viewControllers objectAtIndex:0];        
    [self.tabBarController setSelectedIndex:2];
    mapViewController.location = CLLocationCoordinate2DMake([self.place.lat doubleValue], [self.place.lng doubleValue]);
    [mapViewController zoomToSite];
}

- (IBAction)playPauseCommentry:(id)sender 
{
    if (_audioPlayer.isPlaying) 
    {
        [_audioPlayer stop];
        [self.playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    } 
    else 
    {
        [_audioPlayer play];
        [self.playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
}


#pragma mark - Methods -

- (void)hideImage:(id)sender 
{
    [UIView animateWithDuration:0.5 animations:^
     {
         [sender setAlpha:0.0];
         [sender removeFromSuperview];
     }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Audio player delegates - 

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag 
{
    [self.playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
}

@end
