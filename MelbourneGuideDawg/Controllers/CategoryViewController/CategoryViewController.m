//
//  CategoryViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 04/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategoryViewController.h"

@interface CategoryViewController()
- (void)refreshView;
@end

@implementation CategoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = NSLocalizedString(@"Category", @"Category");
        self.tabBarItem.image = [UIImage imageNamed:@"places-tab.png"];
        self.managedObjectContext = [NSManagedObjectContext sharedInstance];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_tableView release];
    [_pleaseSyncMessage release];
    [_managedObjectContext release];
    [_categories release];
    [_placesViewController release];
    
    [super dealloc];
}

#pragma mark - View lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.placesViewController = [[[PlacesViewController alloc] initWithNibName:@"PlacesView" bundle:nil] autorelease];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView) 
                                                 name:kSyncCompleteNotificaton
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tableViewCell = nil;
    self.tableView = nil;
    self.pleaseSyncMessage = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshView];
    
    if (!self.categories || self.categories.count == 0) {
        self.pleaseSyncMessage.hidden = NO;
    } else {
        self.pleaseSyncMessage.hidden = YES;
    }
}

#pragma mark - Methods -

- (void)refreshView
{
    self.categories = [Category placeCategories];
    [self.tableView reloadData];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Category *category = [self.categories objectAtIndex:indexPath.row];
    
    cell.textLabel.text = category.name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.placesViewController.category = [self.categories objectAtIndex:indexPath.row];
    self.placesViewController.places = ((Category *)[self.categories objectAtIndex:indexPath.row]).sortedPlaces;
    [self.navigationController pushViewController:self.placesViewController animated:YES];    
}

@end
