//
//  SiteDetailViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 18/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceDetailViewController.h"
#import "MapViewController.h"
#import "Place+Extensions.h"

@implementation PlaceDetailViewController

@synthesize webViewController = _webViewController;

@synthesize place = _place;
@synthesize imageButton = _imageButton;
@synthesize titleLabel = _titleLabel;
@synthesize locationLabel = _locationLabel;
@synthesize textLabel = _textLabel;
@synthesize scrollView = _scrollView;
@synthesize viewOnMapButton = _viewOnMapButton;
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
    [_webViewController release];
    
    [_place release];
    [_imageButton release];
    [_titleLabel release];
    [_locationLabel release];
    [_textLabel release];
    [_detailActionsView release];
    [_viewWebsiteButton release];
    
    [super dealloc];
}

#pragma mark - View lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *backButtonImage = [UIImage imageNamed:@"back-btn.png"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.0f, 0.0f, backButtonImage.size.width, backButtonImage.size.height)];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    self.webViewController = [[[WebViewController alloc] initWithNibName:@"WebView" bundle:nil] autorelease];
}

- (void)viewWillAppear:(BOOL)animated 
{
    
    [super viewWillAppear:animated];
    
    if ([[self.navigationController.viewControllers objectAtIndex:0] isKindOfClass:[MapViewController class]]) 
    {
        self.viewOnMapButton.hidden = YES;
        if (self.place.url && ![self.place.url isEqualToString:@""]) {
            self.detailActionsView.hidden = NO;
        } else {
            self.detailActionsView.hidden = YES;
        }
    } 
    else 
    {
        self.detailActionsView.hidden = NO;
        self.viewOnMapButton.hidden = NO;
    }
    
    self.title = self.place.name;
    self.imageButton.adjustsImageWhenHighlighted = NO;
    [self.imageButton setImage:[UIImage imageWithContentsOfFile:[self.place imagePathForType:kPlaceImageTypeNormal]] forState:UIControlStateNormal];
    
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
    self.scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, scrollViewHeight);
    
    if (self.place.url && self.place.url.length > 0) {
        self.viewWebsiteButton.hidden = NO;
    } else {
        self.viewWebsiteButton.hidden = YES;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillAppear:animated];
}

# pragma mark - UI actions - 

- (IBAction)showImage:(id)sender 
{    
    UIButton *largeImage = [UIButton buttonWithType:UIButtonTypeCustom];
    [largeImage setImage:[UIImage imageWithContentsOfFile:[self.place imagePathForType:kPlaceImageTypeNormal]] forState:UIControlStateNormal];
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

    self.webViewController.url = self.place.url;
    self.webViewController.title = self.place.title;
    [self.navigationController pushViewController:self.webViewController animated:YES];
}

- (IBAction)viewMap:(id)sender 
{   
    UINavigationController *mapViewNavigationController = (UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:2];
    MapViewController *mapViewController = [mapViewNavigationController.viewControllers objectAtIndex:0];  
    
    mapViewController.selectedPlaceId = self.place.placeId;
    mapViewController.location = CLLocationCoordinate2DMake([self.place.lat doubleValue], [self.place.lng doubleValue]);
    [mapViewNavigationController popToRootViewControllerAnimated:NO];
    
    [self.tabBarController setSelectedIndex:2];
    
    if (![self.place.category.filterSelected boolValue]) {
        self.place.category.filterSelected = [NSNumber numberWithBool:YES];
        [self.managedObjectContext save];
        [mapViewController refreshView];
    } else {
        [mapViewController zoomToSite];
    }
}

#pragma mark - Methods -

- (void)back:(id)sender 
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)hideImage:(id)sender 
{
    [UIView animateWithDuration:0.5 animations:^
     {
         [sender setAlpha:0.0];
         [sender removeFromSuperview];
     }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

@end
