//
//  SitesViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlacesViewController.h"
#import "Place.h"
#import "PlaceDetailViewController.h"

@interface PlacesViewController()
@end

@implementation PlacesViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize tableViewCell = _tableViewCell;
@synthesize category = _category;
@synthesize places = _places;

#pragma mark - Init -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.managedObjectContext = [NSManagedObjectContext sharedInstance];
    }
    return self;
}

#pragma mark - memory management -

- (void)dealloc 
{    
    [_managedObjectContext release];
    [_category release];
    [super dealloc];
}

#pragma mark - View lifecycle -

- (void)viewDidLoad
{
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = self.category.name;
    [self.tableView reloadData];
}

#pragma mark - Table view data source delegates -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SiteIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"PlaceCell" owner:self options:nil];
        cell = self.tableViewCell;
        self.tableViewCell = nil;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Place *place = [self.places objectAtIndex:indexPath.row];
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:1];
//    [image setImage:[UIImage imageWithData:place.imageTinyData]];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:2];
    label.text = place.name;

    label = (UILabel *)[cell viewWithTag:3];
    label.text = place.address;
    
    label = (UILabel *)[cell viewWithTag:4];
    label.text = place.text;
    
    return cell;
}

#pragma mark - Table view delegates - 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    PlaceDetailViewController *placeDetailViewController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
    placeDetailViewController.place = [self.places objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:placeDetailViewController animated:YES];
    [placeDetailViewController release];     
}

@end
