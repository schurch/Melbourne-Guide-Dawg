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
#import "PlaceDetailFetcher.h"
#import "AppDelegate.h"
#import "FullScreenImageViewer.h"


@interface PlaceDetailViewController()
{
    BOOL _perfomingFetchRequest;
    int _likes;
}
@property (nonatomic, strong) FullScreenImageViewer *imageViewer;
- (void)selectLikeButton;
- (void)deselectLikeButton;
@end


@implementation PlaceDetailViewController

#pragma mark - init / dealloc -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)  {
        self.imageViewer = [[FullScreenImageViewer alloc] init];
    }
    return self;
}


#pragma mark - View lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [Utils generateButtonItemWithImageName:@"back-btn.png" target:self selector:@selector(back:)];
    
    self.webViewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:nil];
    
    self.likesLabel.text = @"0 likes";
    self.commentsLabel.text = @"0 comments";
    
    _perfomingFetchRequest = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.imageButton = nil;
    self.titleLabel = nil;
    self.locationLabel = nil;
    self.textLabel = nil;
    self.scrollView = nil;
    self.viewOnMapButton = nil;
    self.detailActionsView = nil;
    self.viewWebsiteButton = nil;
    self.likesLabel = nil;
    self.commentsLabel = nil;
    self.likeButton = nil;
    self.loadingActivityIndicator = nil;
}

- (void)viewWillAppear:(BOOL)animated 
{
    
    [super viewWillAppear:animated];
    
    _perfomingFetchRequest = YES;
    self.likeButton.hidden = YES;
    [self.loadingActivityIndicator startAnimating];

    
    [PlaceDetailFetcher fetchPlaceDetailsForPlaceID:[self.place.placeId intValue] success:^(int likeCount, int commentCount, BOOL isLiked)
    {
        _likes = likeCount;
        self.likesLabel.text = [NSString stringWithFormat:@"%i likes", _likes];
        self.commentsLabel.text = [NSString stringWithFormat:@"%i comments", commentCount];
        self.likeButton.selected = isLiked;
        _perfomingFetchRequest = NO;
        [self.loadingActivityIndicator stopAnimating];
        self.likeButton.hidden = NO;
    } failure:^(NSString *error) {
        //fail silently
        _perfomingFetchRequest = NO;
        [self.loadingActivityIndicator stopAnimating];
    }];
    
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
    if ([self.place.category.name isEqualToString:@"Toilets"]) {
        [self.imageButton setImage:[UIImage imageNamed:@"toilet.jpg"] forState:UIControlStateNormal];
    } else {
        UIImage *image = [[UIImage imageWithContentsOfFile:[[self.place imagePathForType:kPlaceImageTypeNormal] path]] imageByScalingAndCroppingForSize:CGSizeMake(300, 200)];
        [self.imageButton setImage:image forState:UIControlStateNormal];
    }

    
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
    
    int scrollViewHeight = self.imageButton.frame.size.height + self.titleLabel.frame.size.height + self.locationLabel.frame.size.height + self.textLabel.frame.size.height + 70;
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
    UIImage *image = nil;
    if ([self.place.category.name isEqualToString:@"Toilets"]) {
        image = [UIImage imageNamed:@"toilet.jpg"];
    } else {
        image = [UIImage imageWithContentsOfFile:[[self.place imagePathForType:kPlaceImageTypeNormal] path]];
    }

    [self.imageViewer displayFullscreenImage:image];
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
//    UINavigationController *mapViewNavigationController = (UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:2];
//    MapViewController *mapViewController = [mapViewNavigationController.viewControllers objectAtIndex:0];  
//    
//    mapViewController.selectedPlaceId = self.place.placeId;
//    mapViewController.location = CLLocationCoordinate2DMake([self.place.lat doubleValue], [self.place.lng doubleValue]);
//    [mapViewNavigationController popToRootViewControllerAnimated:NO];
//    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.tabImageView.image = [UIImage imageNamed:@"t-bar-3.png"];
    [self.tabBarController setSelectedIndex:2];
//
//    //make sure the item to show is visible (if the user has hidden their filter)
//    if (![self.place.category.filterSelected boolValue]) {
//        self.place.category.filterSelected = [NSNumber numberWithBool:YES];
//        [self.managedObjectContext save];
//        [mapViewController refreshView];
//    } else {
//        [mapViewController zoomToSite];
//    }
}

- (IBAction)comment:(id)sender
{
    CommentViewController *commentController = [[CommentViewController alloc] initWithNibName:@"CommentView" bundle:nil];
    commentController.placeID = [self.place.placeId intValue];
    commentController.delegate = self;
    [self.navigationController pushViewController:commentController animated:YES];
}

- (IBAction)like:(id)sender
{
    if (_perfomingFetchRequest) {
        return;
    }
    
    _perfomingFetchRequest = YES;
    
    if (self.likeButton.selected) {
        [self deselectLikeButton];
        [PlaceDetailFetcher unlikePlaceWithID:[self.place.placeId intValue] success:^{
            _perfomingFetchRequest = NO;
        } failure:^(NSString *error) {
            [self selectLikeButton];
            _perfomingFetchRequest = NO;
        }];
    } else {
        [self selectLikeButton];
        [PlaceDetailFetcher likePlaceWithID:[self.place.placeId intValue] success:^{
            _perfomingFetchRequest = NO;
        } failure:^(NSString *error) {
            [self deselectLikeButton];
            _perfomingFetchRequest = NO;
        }];
    }
}

#pragma mark - Methods -

- (void)back:(id)sender 
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectLikeButton
{
    self.likeButton.selected = YES;
    _likes += 1;
    self.likesLabel.text = [NSString stringWithFormat:@"%i likes", _likes];
}

- (void)deselectLikeButton
{
    self.likeButton.selected = NO;
    _likes -= 1;
    self.likesLabel.text = [NSString stringWithFormat:@"%i likes", _likes];
}

#pragma mark - comment view controller delegates -

- (void)commmentCountUpdated:(int)count
{
    self.commentsLabel.text = [NSString stringWithFormat:@"%i comments", count];
}

@end
