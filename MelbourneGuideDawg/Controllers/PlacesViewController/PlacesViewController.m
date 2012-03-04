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

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize tableViewCell = _tableViewCell;

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
    [_fetchedResultsController release];
    self.fetchedResultsController.delegate = nil;
    
    [_managedObjectContext release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) 
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);
	}
}

#pragma mark - Methods -

- (NSFetchedResultsController *)fetchedResultsController 
{    
    if (_fetchedResultsController != nil) 
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:10];
    
    NSFetchedResultsController *theFetchedResultsController = 
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                        managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil 
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    [sort release];
    [fetchRequest release];
    [theFetchedResultsController release];
    
    return _fetchedResultsController;    
}

#pragma mark - Table view data source delegates -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
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
    
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:1];
    [image setImage:[UIImage imageWithData:place.imageTinyData]];
    
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
    placeDetailViewController.place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:placeDetailViewController animated:YES];
    [placeDetailViewController release];     
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller 
{
    [self.tableView beginUpdates];
}

@end
