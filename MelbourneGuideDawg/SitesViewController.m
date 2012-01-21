//
//  SitesViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SitesViewController.h"
#import "Site.h"
#import "Image.h"
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

- (void)addDummyDataWithImage:(NSString *)imageName context:(NSManagedObjectContext *)context lat:(double)lat lng:(double)lng {
    Site *site = [NSEntityDescription insertNewObjectForEntityForName:@"Site" inManagedObjectContext:context];
    
    static int siteId = 1;
    
    site.siteId = [NSNumber numberWithInt:siteId];
    site.name = @"VIC Nat Gallery";
    site.location = @"6 Warburton St, Brunswick, 3006";
    
    NSString *tinyImageName = [NSString stringWithFormat:@"%@_tiny.jpg", imageName];
    NSString *thumbImageName = [NSString stringWithFormat:@"%@_thumb.jpg", imageName];
    NSString *smallImageName = [NSString stringWithFormat:@"%@_small.jpg", imageName];
    NSString *fullImageName = [NSString stringWithFormat:@"%@.jpg", imageName];

    NSData *imageThumbData = UIImagePNGRepresentation([UIImage imageNamed:thumbImageName]);
    NSData *imageTinyData = UIImagePNGRepresentation([UIImage imageNamed:tinyImageName]);

    site.imageTinyData = imageTinyData;
    site.imageThumbData = imageThumbData;
    
    Image *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
    image.smallFileName = smallImageName;
    image.imageFileName = fullImageName;
    
    [site addImages:[NSSet setWithObjects:image, nil]];
    
    site.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse accumsan leo eu felis pharetra ut semper ipsum pellentesque. Sed sed erat ut mi ullamcorper auctor. Nunc faucibus volutpat metus. Suspendisse quis purus at sem laoreet fringilla rhoncus sed leo. Maecenas purus odio, suscipit ac rhoncus id, ultrices eget nisl. Pellentesque tempus nisl eget leo volutpat scelerisque. Nam pretium odio vel enim adipiscing sit amet tristique nisl ultricies. \r\n \r\nAenean et urna enim, a tincidunt dui. Curabitur rutrum ligula ut nisl viverra gravida ut et mauris. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Pellentesque suscipit lobortis auctor. Integer dignissim sem quis eros tempor et elementum leo fringilla. Duis pulvinar dictum neque, ut aliquet lacus porttitor malesuada. Vivamus sed arcu quis dolor elementum rhoncus. Nam aliquam semper diam, consequat faucibus erat varius sed. Nulla facilisi.";
    
    site.date = [NSDate date]; 
    site.lat = [NSNumber numberWithDouble:lat];
    site.lng = [NSNumber numberWithDouble:lng];

    
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
    
//    -37.812225 144.963055
//    -37.80490	144.97121
//    -37.82036	144.94477
//    -37.81290	144.95190
//    -37.81507	144.97396
//    -37.82423	144.96958
//    -37.81941	144.97516
//    -37.81575	144.96263
    
//    for (int i = 0; i < 10; i++) {
//        [self addDummyDataWithImage:@"melbourne1" context:context lat:-37.812225 lng:144.963055];
//        [self addDummyDataWithImage:@"melbourne2" context:context lat:-37.80490 lng:144.97121];    
//        [self addDummyDataWithImage:@"melbourne3" context:context lat:-37.82036 lng:144.94477];    
//        [self addDummyDataWithImage:@"melbourne4" context:context lat:-37.81290 lng:144.95190];    
//        [self addDummyDataWithImage:@"melbourne5" context:context lat:-37.81507 lng:144.97396];    
//        [self addDummyDataWithImage:@"melbourne6" context:context lat:-37.82423 lng:144.96958];    
//        [self addDummyDataWithImage:@"melbourne7" context:context lat:-37.81941 lng:144.97516];    
//        [self addDummyDataWithImage:@"melbourne8" context:context lat:-37.81575 lng:144.96263];  
//    }
      
    
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
