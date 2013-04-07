//
//  FirstViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <math.h>
#import "HomeViewController.h"
#import "MBProgressHUD.h"

#define INTRO_OFFSET 250

#define SYNC_Y_OFFSET -40
#define PULL_TO_SYNC_TEXT @"Pull to synchronize..."
#define RELEASE_TO_SYNC_TEXT @"Release to synchronize..."
#define LOADING_TEXT @"Initializing..."

#define kShownHelperUserSettingsKey @"showHelper"

@interface HomeViewController()
- (void)startLoading;
- (void)stopLoadingWithMessage:(NSString *)message wasSuccess:(BOOL)wasSuccess;
- (void)stopLoadingComplete;
- (void)sync;
@end


@implementation HomeViewController

#pragma mark - Init -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = NSLocalizedString(@"Home", @"Home");
        self.tabBarItem.image = [UIImage imageNamed:@"home-tab.png"];
    }
    return self;
}

#pragma mark - Memory management -


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSBundle mainBundle] loadNibNamed:@"IntroductionView" owner:self options:nil];
    self.introductionView.frame = CGRectMake(0, INTRO_OFFSET, self.introductionView.frame.size.width, self.introductionView.frame.size.height);
    self.introductionView.backgroundColor = [UIColor clearColor];
    
    [self.introScrollView addSubview:self.introductionView];
    int contentSizeHeight = INTRO_OFFSET + self.introductionView.frame.size.height;
    self.introScrollView.contentSize = CGSizeMake(320, contentSizeHeight);
    
    int paddingYOffset = self.introductionView.frame.origin.y + self.introductionView.frame.size.height;
    UIView *bottomPadding = [[UIView alloc] initWithFrame:CGRectMake(0, paddingYOffset, 320, 400)];
    bottomPadding.backgroundColor = [UIColor blackColor];
    [self.introScrollView addSubview:bottomPadding];
    
    BOOL shownHelper = [[NSUserDefaults standardUserDefaults] boolForKey:kShownHelperUserSettingsKey];
    if (!shownHelper) {
        self.pullToSyncHelper.hidden = NO;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kShownHelperUserSettingsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        self.pullToSyncHelper.hidden = YES;
    }
    
    self.syncBackground.layer.cornerRadius = 5;
    [self.syncBackground.layer setMasksToBounds:YES];
    self.syncBackground.alpha = 0.0;
    self.syncArrow.alpha = 0.0;
    self.syncLabel.alpha = 0.0;
    self.syncLabel.text = PULL_TO_SYNC_TEXT;
    self.syncTickCrossImage.hidden = YES;
    
    self.syncManager = [[SyncManager alloc] init];
}

- (void)viewDidUnload
{
    self.syncLabel = nil;
    self.syncActivityIndicator = nil;
    self.syncArrow = nil;
    self.syncBackground = nil;
    self.syncTickCrossImage = nil;
    self.introScrollView = nil;
    self.introductionView = nil;
    self.introHeaderLabel = nil;
    self.introTextLabel = nil;
    self.syncButton = nil;
    self.pullToSyncHelper = nil;

    [super viewDidUnload];
}

#pragma mark - UI Actions -

- (IBAction)visitWebsite:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Visit website?" message:@"Open Safari to view our website?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open Safari", nil];
    [alertView show];
}

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
        return;
    }
    
    MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
    composer.navigationBar.tintColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    composer.mailComposeDelegate = self;
    
    [composer setToRecipients:[NSArray arrayWithObject:@"info@melbourneguidedawg.com"]];
    
    [self presentModalViewController:composer animated:YES];
}

- (IBAction)hideSyncButton:(id)sender
{
    self.pullToSyncHelper.hidden = YES;
}

#pragma mark - Mail delegates -

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - alert view delegate -

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.melbourneguidedawg.com"]];
    }
}

#pragma mark - Sync view methods -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_isLoading) return;
    _isDragging = YES;
}

#define ALPHA_MAX_CONTENT_OFFSET -15.0f

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (_isLoading) {
        return;
    }
    
    float contentOffset = self.introScrollView.contentOffset.y;
    
    //fade in if dragged
    float alpha = contentOffset / ALPHA_MAX_CONTENT_OFFSET;
    self.syncLabel.alpha = alpha;
    self.syncArrow.alpha = alpha;
    self.syncBackground.alpha = fmin(alpha, 0.6);
    
    if (_isDragging && contentOffset < -30) {     
        [UIView beginAnimations:nil context:NULL];
        if (contentOffset < SYNC_Y_OFFSET) {
            self.syncLabel.text = RELEASE_TO_SYNC_TEXT;
            [self.syncArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        } else { 
            self.syncLabel.text = PULL_TO_SYNC_TEXT;
            [self.syncArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_isLoading) return;
    _isDragging = NO;
    
    if (scrollView.contentOffset.y <= SYNC_Y_OFFSET) {
        // Released above the header
        [self startLoading];
    }
}

- (void)startLoading {
    _isLoading = YES;
    self.view.window.userInteractionEnabled = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.syncLabel.text = LOADING_TEXT;
    self.syncArrow.hidden = YES;
    [self.syncActivityIndicator startAnimating];
    [UIView commitAnimations];
    
    [self sync];
}

- (void)stopLoadingWithMessage:(NSString *)message wasSuccess:(BOOL)wasSuccess
{
    [self.syncActivityIndicator stopAnimating];
    
    if (wasSuccess) {
        self.syncTickCrossImage.image = [UIImage imageNamed:@"white-tick.png"];
    } else {
        self.syncTickCrossImage.image = [UIImage imageNamed:@"white-cross.png"];
    }
    self.syncTickCrossImage.hidden = NO;
    
    self.syncLabel.text = message;
    [self performSelector:@selector(stopLoadingComplete) withObject:self afterDelay:2];
}

- (void)stopLoadingComplete {
    
    self.syncLabel.alpha = 0.0;
    self.syncArrow.alpha = 0.0;
    self.syncBackground.alpha = 0.0;
    
    self.syncLabel.text = PULL_TO_SYNC_TEXT;
    [self.syncArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    self.syncArrow.hidden = NO;
    self.syncTickCrossImage.hidden = YES;
    
    self.view.window.userInteractionEnabled = YES;
    
    _isLoading = NO;
}

- (void)sync {
    NSLog(@"Syncing..");
    
    [self.syncManager syncWithCompletionBlock:^{
        NSLog(@"Success syncing the data.");
        [self stopLoadingWithMessage:@"Synchronization complete." wasSuccess:YES];
    } errorBlock:^(NSError *error){
        NSLog(@"There was an error syncing the data.");
        
        [self stopLoadingWithMessage:@"An error occured. Please try again later." wasSuccess:NO];
        
        if (error) {
            NSLog(@"Unresolved error when downloading data: %@, %@", error, [error userInfo]);
#if DEBUG
//            abort();
#endif
        }
        
    } progressBlock:^(NSString *progressMessage){
        self.syncLabel.text = progressMessage;
    }];
}

@end
