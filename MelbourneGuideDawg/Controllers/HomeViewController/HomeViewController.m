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
#import "MTStatusBarOverlay.h"

#define INTRO_OFFSET 250

#define SYNC_Y_OFFSET -40
#define PULL_TO_SYNC_TEXT @"Pull to synchronize..."
#define RELEASE_TO_SYNC_TEXT @"Release to synchronize..."
#define LOADING_TEXT @"Initializing..."

@interface HomeViewController()
- (void)startLoading;
- (void)stopLoadingWithMessage:(NSString *)message;
- (void)stopLoadingComplete;
- (void)sync;
@end


@implementation HomeViewController

@synthesize syncLabel = _syncLabel;
@synthesize syncArrow = _syncArrow;
@synthesize syncBackground = _syncBackground;
@synthesize syncActivityIndicator = _syncActivityIndicator;

@synthesize introScrollView = _introScrollView;
@synthesize introductionView = _introductionView;
@synthesize introHeaderLabel = _introHeaderLabel;
@synthesize introTextLabel = _introTextLabel;
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
    }
    return self;
}

#pragma mark - Memory management -

- (void)dealloc 
{
    [_syncBackground release];
    [_syncArrow release];
    [_syncButton release];
    [_syncActivityIndicator release];
    
    [_introHeaderLabel release];
    [_introScrollView release];
    [_introductionView release];
    [_introTextLabel release];
    [_syncButton release];
    [_syncManager release];
    
    [super dealloc];
}

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
    [bottomPadding release];
    
    self.syncBackground.layer.cornerRadius = 5;
    [self.syncBackground.layer setMasksToBounds:YES];
    self.syncBackground.alpha = 0.0;
    self.syncArrow.alpha = 0.0;
    self.syncLabel.alpha = 0.0;
    self.syncLabel.text = PULL_TO_SYNC_TEXT;
    
    self.syncManager = [[[SyncManager alloc] init] autorelease];
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

#pragma mark - Mail delegates -

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{    
    [self dismissModalViewControllerAnimated:YES];
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

- (void)stopLoadingWithMessage:(NSString *)message {
    _isLoading = NO;
    
    [self.syncActivityIndicator stopAnimating];
    self.syncLabel.text = message;
    [self performSelector:@selector(stopLoadingComplete) withObject:self afterDelay:1.5];
}

- (void)stopLoadingComplete {
    
    self.syncLabel.alpha = 0.0;
    self.syncArrow.alpha = 0.0;
    self.syncBackground.alpha = 0.0;
    
    self.syncLabel.text = PULL_TO_SYNC_TEXT;
    [self.syncArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    self.syncArrow.hidden = NO;
    
    self.view.window.userInteractionEnabled = YES;
}

- (void)sync {
    NSLog(@"Syncing..");
    
    [self.syncManager syncWithCompletionBlock:^{
        NSLog(@"Success syncing the data.");
        [self stopLoadingWithMessage:@"Synchronization complete"];
    } errorBlock:^(NSError *error){
        NSLog(@"There was an error syncing the data.");
        [self stopLoadingWithMessage:@"An error occured"];
        
        if (error) {
            NSLog(@"Unresolved error when downloading data: %@, %@", error, [error userInfo]);
#if DEBUG
            abort();
#endif
        }
        
    } progressBlock:^(NSString *progressMessage){
        self.syncLabel.text = progressMessage;
    }];
}

@end
