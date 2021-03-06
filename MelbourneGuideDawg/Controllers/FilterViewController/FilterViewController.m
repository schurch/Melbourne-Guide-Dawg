//
//  CategoryViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 04/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController()
- (void)refreshView;
@end

@implementation FilterViewController


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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _delegate = nil;
    
}

#pragma mark - View lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBar.topItem.rightBarButtonItem = [Utils generateButtonItemWithImageName:@"close-btn.png" target:self selector:@selector(close:)];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView) 
                                                 name:kSyncCompleteNotificaton
                                               object:nil];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.tableView = nil;
    self.navBar = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _filterChanged = NO;
    [self refreshView];
}

#pragma mark - Methods -

- (void)refreshView
{
    self.categories = [Category placeCategoriesWithToilets:YES];
    [self.tableView reloadData];
}

- (void)close:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(filterChanged:)]) {
        [self.delegate filterChanged:_filterChanged];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Category *category = [self.categories objectAtIndex:indexPath.row];
    
    cell.textLabel.text = category.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = [category.filterSelected boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _filterChanged = YES;
    
    Category *category = [self.categories objectAtIndex:indexPath.row];
    category.filterSelected = [category.filterSelected boolValue] ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
    [self.managedObjectContext save];
    
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = [category.filterSelected boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    [self.tableView reloadData];
}

@end
