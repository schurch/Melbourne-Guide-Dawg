//
//  FirstViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#import "SyncManager.h"

@interface HomeViewController : UIViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
    BOOL _isLoading;
    BOOL _isDragging;
}

@property (nonatomic, retain) IBOutlet UILabel *syncLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *syncActivityIndicator;
@property (nonatomic, retain) IBOutlet UIImageView *syncArrow;
@property (nonatomic, retain) IBOutlet UIView *syncBackground;
@property (nonatomic, retain) IBOutlet UIImageView *syncTickCrossImage;
@property (nonatomic, retain) IBOutlet UIScrollView *introScrollView;
@property (nonatomic, retain) IBOutlet UIView *introductionView;
@property (nonatomic, retain) IBOutlet UILabel *introHeaderLabel;
@property (nonatomic, retain) IBOutlet UILabel *introTextLabel;
@property (nonatomic, retain) IBOutlet UIButton *syncButton;
@property (nonatomic, retain) IBOutlet UIButton *pullToSyncHelper;
@property (nonatomic, retain) SyncManager *syncManager;

- (IBAction)visitWebsite:(id)sender;
- (IBAction)emailFeedback:(id)sender;
- (IBAction)hideSyncButton:(id)sender;

@end
