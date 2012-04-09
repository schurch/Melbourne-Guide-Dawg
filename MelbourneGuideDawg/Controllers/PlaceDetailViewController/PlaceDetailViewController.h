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

@interface PlaceDetailViewController : UIViewController<AVAudioPlayerDelegate> 
{
    AVAudioPlayer *_audioPlayer;
}

@property (nonatomic, retain) Place *place;
@property (nonatomic, retain) IBOutlet UIButton *imageButton;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIButton *viewOnMapButton;
@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UIView *detailActionsView;
@property (nonatomic, retain) IBOutlet UIButton *viewWebsiteButton;

- (IBAction)visitWebSite:(id)sender;
- (IBAction)showImage:(id)sender;
- (IBAction)viewMap:(id)sender;
- (IBAction)playPauseCommentry:(id)sender;

@end
