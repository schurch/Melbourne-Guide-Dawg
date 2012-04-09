//
//  FirstViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "MBProgressHUD.h"

#define INTRO_OFFSET 250

@implementation HomeViewController

@synthesize introScrollView = _introScrollView;
@synthesize introductionView = _introductionView;
@synthesize introHeaderLabel = _introHeaderLabel;
@synthesize syncButton = _syncButton;
@synthesize syncManager = _syncManager;

#pragma mark - Init -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = NSLocalizedString(@"Home", @"Home");
        self.tabBarItem.image = [UIImage imageNamed:@"home_tab"];
        [[NSBundle mainBundle] loadNibNamed:@"IntroductionView" owner:self options:nil];
    }
    return self;
}

#pragma mark - Memory management -

- (void)dealloc 
{
    [_introHeaderLabel release];
    [_introScrollView release];
    [_introductionView release];
    [_syncButton release];
    [_syncManager release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.introductionView.frame = CGRectMake(20, INTRO_OFFSET, self.introductionView.frame.size.width, self.introductionView.frame.size.height);
    self.introductionView.backgroundColor = [UIColor clearColor];
    [self.introScrollView addSubview:self.introductionView];
    int contentSizeHeight = INTRO_OFFSET + self.introductionView.frame.size.height;
    self.introScrollView.contentSize = CGSizeMake(320, contentSizeHeight);
    
    int paddingYOffset = self.introductionView.frame.origin.y + self.introductionView.frame.size.height;
    UIView *bottomPadding = [[UIView alloc] initWithFrame:CGRectMake(20, paddingYOffset, 320, 400)];
    bottomPadding.backgroundColor = [UIColor blackColor];
    [self.introScrollView addSubview:bottomPadding];
    [bottomPadding release];
    
    self.syncManager = [[SyncManager alloc] init];
}

#pragma mark - UI Actions -

- (IBAction)emailFeedback:(id)sender 
{
    if (![MFMailComposeViewController canSendMail]) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to send email" 
                                                        message:@"Email is not correctly configured on this device." 
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
    composer.navigationBar.tintColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    composer.mailComposeDelegate = self;
    
    [composer setToRecipients:[NSArray arrayWithObject:@"feedback@melbourneguidedawg.com"]];
    [composer setSubject:@"Feedback"];
    
    [self presentModalViewController:composer animated:YES];
    [composer release];  
}

- (IBAction)sync:(id)sender
{
    NSLog(@"Syncing..");
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Downloading...";
    
    [self.syncManager syncWithCompletionBlock:^{
        NSLog(@"Success syncing the data.");
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } errorBlock:^(NSError *error){
        NSLog(@"There was an error syncing the data.");
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (error) {
            NSLog(@"Unresolved error when downloading data: %@, %@", error, [error userInfo]);
#if DEBUG
            abort();
#endif
        }
    }];
    
}

#pragma mark - Mail delegates -

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{    
    [self dismissModalViewControllerAnimated:YES];
}

@end
