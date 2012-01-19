//
//  SitesViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SitesViewController.h"
#import "Site.h"
#import "SiteDetailViewController.h"

@implementation SitesViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize tableViewCell = _tableViewCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Sites", @"Sites");
        self.tabBarItem.image = [UIImage imageNamed:@"camera_tab"];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"Sites", @"Sites");
        self.tabBarItem.image = [UIImage imageNamed:@"camera_tab"];
    }
    return self;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site" inManagedObjectContext:self.managedObjectContext];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addDummyDataWithImage:(NSString *)imageName context:(NSManagedObjectContext *)context {
    Site *site = [NSEntityDescription insertNewObjectForEntityForName:@"Site" inManagedObjectContext:context];
    
    static int siteId = 1;
    
    site.siteId = [NSNumber numberWithInt:siteId];
    site.name = @"NSG Gallery";
    site.location = @"6 Warburton St, Brunswick";
    NSString *thumbImageName = [NSString stringWithFormat:@"%@_thumb.jpg", imageName];
    NSString *fullImageName = [NSString stringWithFormat:@"%@.jpg", imageName];

    NSData *imageThumbData = UIImagePNGRepresentation([UIImage imageNamed:thumbImageName]);

    site.imageThumbData = imageThumbData;
    site.imageFileName = fullImageName;
    
    site.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse accumsan leo eu felis pharetra ut semper ipsum pellentesque. Sed sed erat ut mi ullamcorper auctor. Nunc faucibus volutpat metus. Suspendisse quis purus at sem laoreet fringilla rhoncus sed leo. Maecenas purus odio, suscipit ac rhoncus id, ultrices eget nisl. Pellentesque tempus nisl eget leo volutpat scelerisque. Nam pretium odio vel enim adipiscing sit amet tristique nisl ultricies. \r\n \r\nAenean et urna enim, a tincidunt dui. Curabitur rutrum ligula ut nisl viverra gravida ut et mauris. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Pellentesque suscipit lobortis auctor. Integer dignissim sem quis eros tempor et elementum leo fringilla. Duis pulvinar dictum neque, ut aliquet lacus porttitor malesuada. Vivamus sed arcu quis dolor elementum rhoncus. Nam aliquam semper diam, consequat faucibus erat varius sed. Nulla facilisi.";
    
    site.date = [NSDate date]; 
    site.lat = [NSNumber numberWithDouble:-37.812225];
    site.lng = [NSNumber numberWithDouble:144.963055];

    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
    
    siteId++;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);
	}
 
    
//    NSError *error;
//    NSManagedObjectContext *context = self.managedObjectContext;
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription 
//                                   entityForName:@"Site" inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    self.sites = [context executeFetchRequest:fetchRequest error:&error];
//    [fetchRequest release];
    
//    [self addDummyDataWithImage:@"melbourne1" context:context];
//    [self addDummyDataWithImage:@"melbourne2" context:context];
//    [self addDummyDataWithImage:@"melbourne3" context:context];
//    [self addDummyDataWithImage:@"melbourne1" context:context];
//    [self addDummyDataWithImage:@"melbourne2" context:context];
//    [self addDummyDataWithImage:@"melbourne3" context:context];
//    [self addDummyDataWithImage:@"melbourne1" context:context];
//    [self addDummyDataWithImage:@"melbourne2" context:context];
//    [self addDummyDataWithImage:@"melbourne3" context:context];
//    [self addDummyDataWithImage:@"melbourne1" context:context];
//    [self addDummyDataWithImage:@"melbourne2" context:context];
//    [self addDummyDataWithImage:@"melbourne3" context:context];
//    [self addDummyDataWithImage:@"melbourne1" context:context];
//    [self addDummyDataWithImage:@"melbourne2" context:context];
//    [self addDummyDataWithImage:@"melbourne3" context:context];
//    [self addDummyDataWithImage:@"melbourne1" context:context];
//    [self addDummyDataWithImage:@"melbourne2" context:context];
//    [self addDummyDataWithImage:@"melbourne3" context:context];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.fetchedResultsController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    NSError *error;
//    NSManagedObjectContext *context = self.managedObjectContext;
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription 
//                                   entityForName:@"Site" inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    for (Site *site in fetchedObjects) {
//        NSLog(@"Title: %@", site.title);
//        NSLog(@"Location: %@", site.location);
//        NSLog(@"Text: %@", site.text);
//    }        
//    [fetchRequest release];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

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
        [[NSBundle mainBundle] loadNibNamed:@"SiteTableCell" owner:self options:nil];
        cell = self.tableViewCell;
        self.tableViewCell = nil;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Site *site = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:1];
    [image setImage:[UIImage imageWithData:site.imageThumbData]];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:2];
    label.text = site.name;

    label = (UILabel *)[cell viewWithTag:3];
    label.text = site.location;
    
    label = (UILabel *)[cell viewWithTag:4];
    label.text = site.text;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    SiteDetailViewController *detailViewController = [[SiteDetailViewController alloc] initWithNibName:@"SiteDetailViewController" bundle:nil];
    detailViewController.site = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];     
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

#pragma mark memory management

- (void)dealloc {
    [_managedObjectContext release];
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
}

@end
