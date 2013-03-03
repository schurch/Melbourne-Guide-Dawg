//
//  MapViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "Place.h"
#import "Place+Extensions.h"
#import "PlaceDetailViewController.h"
#import "Category.h"
#import "Category+Extensions.h"


@interface MapViewController()
@property (nonatomic, retain) FilterViewController *filterViewController;
- (void)filter:(id)sender;
@end

@implementation MapViewController

#pragma mark - Init -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageNamed:@"map-tab.png"];
        self.managedObjectContext = [NSManagedObjectContext sharedInstance];
    }
    return self;
}

#pragma mark - Memory management -

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_filterViewController release];
    [_managedObjectContext release];
    
    [super dealloc];
}

#pragma mark - View lifecycle -

- (void)viewDidLoad 
{
    [super viewDidLoad];
    

    self.navigationItem.leftBarButtonItem = [Utils generateButtonItemWithImageName:@"locate-btn.png" target:self selector:@selector(locate:)];
    self.navigationItem.rightBarButtonItem = [Utils generateButtonItemWithImageName:@"filter-btn.png" target:self selector:@selector(filter:)];
    
    self.filterViewController = [[[FilterViewController alloc] initWithNibName:@"FilterView" bundle:nil] autorelease];
    self.filterViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.filterViewController.delegate = self;

    [self refreshView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Methods - 

- (void)refreshView
{
    
}

- (void)locate:(id)sender
{
    
}

- (void)filter:(id)sender 
{
    [self presentViewController:self.filterViewController animated:YES completion:nil];
}

#pragma mark - Filter view delegates -

- (void)filterChanged:(BOOL)didFilterChange
{
    if (didFilterChange) 
    {
        [self refreshView];   
    }
    
    [self.filterViewController dismissModalViewControllerAnimated:YES];
}

@end
