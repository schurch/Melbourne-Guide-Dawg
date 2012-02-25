//
//  SitesViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlacesViewController.h"
#import "Place.h"
#import "Image.h"
#import "PlaceDetailViewController.h"

@interface PlacesViewController()
- (void)addDummyDataWithImage:(NSString *)imageName context:(NSManagedObjectContext *)context lat:(double)lat lng:(double)lng;
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
        self.title = NSLocalizedString(@"Places", @"Places");
        self.tabBarItem.image = [UIImage imageNamed:@"camera_tab"];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
        self.title = NSLocalizedString(@"Places", @"Places");
        self.tabBarItem.image = [UIImage imageNamed:@"camera_tab"];
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
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);
	}
 
    
//    NSManagedObjectContext *context = self.managedObjectContext;
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription 
//                                   entityForName:@"Site" inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    self.places = [context executeFetchRequest:fetchRequest error:&error];
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

- (void)addDummyDataWithImage:(NSString *)imageName context:(NSManagedObjectContext *)context lat:(double)lat lng:(double)lng 
{
    Place *place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
    
    static int placeId = 1;
    
    place.placeId = [NSNumber numberWithInt:placeId];
    place.name = @"VIC Nat Gallery";
    place.location = @"6 Warburton St, Brunswick, 3006";
    
    NSString *tinyImageName = [NSString stringWithFormat:@"%@_tiny.jpg", imageName];
    NSString *thumbImageName = [NSString stringWithFormat:@"%@_thumb.jpg", imageName];
    NSString *smallImageName = [NSString stringWithFormat:@"%@_small.jpg", imageName];
    NSString *fullImageName = [NSString stringWithFormat:@"%@.jpg", imageName];
    
    NSData *imageThumbData = UIImagePNGRepresentation([UIImage imageNamed:thumbImageName]);
    NSData *imageTinyData = UIImagePNGRepresentation([UIImage imageNamed:tinyImageName]);
    
    place.imageTinyData = imageTinyData;
    place.imageThumbData = imageThumbData;
    
    Image *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:context];
    image.smallFileName = smallImageName;
    image.imageFileName = fullImageName;
    
    [place addImages:[NSSet setWithObjects:image, nil]];
    
    place.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse accumsan leo eu felis pharetra ut semper ipsum pellentesque. Sed sed erat ut mi ullamcorper auctor. Nunc faucibus volutpat metus. Suspendisse quis purus at sem laoreet fringilla rhoncus sed leo. Maecenas purus odio, suscipit ac rhoncus id, ultrices eget nisl. Pellentesque tempus nisl eget leo volutpat scelerisque. Nam pretium odio vel enim adipiscing sit amet tristique nisl ultricies. \r\n \r\nAenean et urna enim, a tincidunt dui. Curabitur rutrum ligula ut nisl viverra gravida ut et mauris. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Pellentesque suscipit lobortis auctor. Integer dignissim sem quis eros tempor et elementum leo fringilla. Duis pulvinar dictum neque, ut aliquet lacus porttitor malesuada. Vivamus sed arcu quis dolor elementum rhoncus. Nam aliquam semper diam, consequat faucibus erat varius sed. Nulla facilisi.";
    
    place.date = [NSDate date]; 
    place.lat = [NSNumber numberWithDouble:lat];
    place.lng = [NSNumber numberWithDouble:lng];
    
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
    
    placeId++;
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
    [image setImage:[UIImage imageWithData:place.imageThumbData]];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:2];
    label.text = place.name;

    label = (UILabel *)[cell viewWithTag:3];
    label.text = place.location;
    
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
