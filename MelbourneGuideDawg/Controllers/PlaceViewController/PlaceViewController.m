//
//  PlaceViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 25/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaceViewController.h"

@implementation PlaceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.managedObjectContext = [NSManagedObjectContext sharedInstance];
    }
    return self;
}

- (void)dealloc 
{   
    [_managedObjectContext release];    
    [super dealloc];
}

#pragma mark - View lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(syncFinished:) 
                                                 name:kSyncCompleteNotificaton
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Methods -

- (void)syncFinished:(NSNotification *)notification
{
    if (self.navigationController) 
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    [self refreshView];
}

- (void)refreshView
{
    //implement in subclass
}

@end
