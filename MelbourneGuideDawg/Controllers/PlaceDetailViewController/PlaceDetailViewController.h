//
//  SiteDetailViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 18/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"
#import <AVFoundation/AVFoundation.h>
#import "WebViewController.h"
#import "PlaceViewController.h"
#import "CommentViewController.h"

@interface PlaceDetailViewController : PlaceViewController<CommentViewControllerDelegate>

@property (nonatomic, strong) WebViewController *webViewController;
@property (nonatomic, strong) Place *place;
@property (nonatomic, strong) IBOutlet UIButton *imageButton;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIButton *viewOnMapButton;
@property (nonatomic, strong) IBOutlet UIView *detailActionsView;
@property (nonatomic, strong) IBOutlet UIButton *viewWebsiteButton;
@property (nonatomic, strong) IBOutlet UILabel *likesLabel;
@property (nonatomic, strong) IBOutlet UILabel *commentsLabel;
@property (nonatomic, strong) IBOutlet UIButton *likeButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingActivityIndicator;

- (IBAction)visitWebSite:(id)sender;
- (IBAction)showImage:(id)sender;
- (IBAction)viewMap:(id)sender;
- (IBAction)comment:(id)sender;
- (IBAction)like:(id)sender;

@end
