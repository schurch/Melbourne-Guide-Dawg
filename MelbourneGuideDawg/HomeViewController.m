//
//  FirstViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"

#define INTRO_OFFSET 250

@implementation HomeViewController

@synthesize introScrollView = _introScrollView;
@synthesize introductionView = _introductionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Home", @"Home");
        self.tabBarItem.image = [UIImage imageNamed:@"home_tab"];
        [[NSBundle mainBundle] loadNibNamed:@"IntroductionView" owner:self options:nil];
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
