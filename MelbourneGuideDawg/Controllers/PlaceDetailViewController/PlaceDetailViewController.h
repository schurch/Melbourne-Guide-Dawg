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

@interface PlaceDetailViewController : PlaceViewController 

@property (nonatomic, retain) WebViewController *webViewController;
@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) IBOutlet UIButton *imageButton;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIButton *viewOnMapButton;
@property (nonatomic, retain) IBOutlet UIView *detailActionsView;
@property (nonatomic, retain) IBOutlet UIButton *viewWebsiteButton;
@property (nonatomic, retain) IBOutlet UILabel *likesLabel;
@property (nonatomic, retain) IBOutlet UILabel *commentsLabel;
@property (nonatomic, retain) IBOutlet UIButton *likeButton;

- (IBAction)visitWebSite:(id)sender;
- (IBAction)showImage:(id)sender;
- (IBAction)viewMap:(id)sender;
- (IBAction)comment:(id)sender;
- (IBAction)like:(id)sender;

@end
