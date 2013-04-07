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

@property (nonatomic, strong) IBOutlet UILabel *syncLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *syncActivityIndicator;
@property (nonatomic, strong) IBOutlet UIImageView *syncArrow;
@property (nonatomic, strong) IBOutlet UIView *syncBackground;
@property (nonatomic, strong) IBOutlet UIImageView *syncTickCrossImage;
@property (nonatomic, strong) IBOutlet UIScrollView *introScrollView;
@property (nonatomic, strong) IBOutlet UIView *introductionView;
@property (nonatomic, strong) IBOutlet UILabel *introHeaderLabel;
@property (nonatomic, strong) IBOutlet UILabel *introTextLabel;
@property (nonatomic, strong) IBOutlet UIButton *syncButton;
@property (nonatomic, strong) IBOutlet UIButton *pullToSyncHelper;
@property (nonatomic, strong) SyncManager *syncManager;

- (IBAction)visitWebsite:(id)sender;
- (IBAction)emailFeedback:(id)sender;
- (IBAction)hideSyncButton:(id)sender;

@end
