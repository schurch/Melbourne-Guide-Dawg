//
//  FirstViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SyncManager.h"

@interface HomeViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *introScrollView;
@property (nonatomic, retain) IBOutlet UIView *introductionView;
@property (nonatomic, retain) IBOutlet UILabel *introHeaderLabel;
@property (nonatomic, retain) IBOutlet UIButton *syncButton;
@property (nonatomic, retain) SyncManager *syncManager;

- (IBAction)emailFeedback:(id)sender;
- (IBAction)sync:(id)sender;

@end
