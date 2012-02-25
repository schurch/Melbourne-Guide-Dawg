//
//  FirstViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface HomeViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    UIScrollView *_introScrollView;
    UIView *_introductionView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *introScrollView;
@property (nonatomic, retain) IBOutlet UIView *introductionView;
@property (nonatomic, retain) IBOutlet UILabel *introHeaderLabel;

- (IBAction)emailFeedback:(id)sender;

@end
