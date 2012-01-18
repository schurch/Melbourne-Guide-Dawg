//
//  SitesViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SitesViewController.h"
#import "Site.h"
#import "SiteDetail.h"
#import "SiteDetailViewController.h"

@implementation SitesViewController

@synthesize navigationController = _navigationController;
@synthesize sites = _sites;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addDummyDataWithImage:(NSString *)imageName context:(NSManagedObjectContext *)context{
    Site *site = [NSEntityDescription insertNewObjectForEntityForName:@"Site" inManagedObjectContext:context];
    
    site.title = @"Something Awesome";
    site.locationText = @"6 Warburton St, Brunswick";
    NSString *thumbImageName = [NSString stringWithFormat:@"%@_thumb.jpg", imageName];
    NSString *fullImageName = [NSString stringWithFormat:@"%@.jpg", imageName];

    NSData *imageThumbData = UIImagePNGRepresentation([UIImage imageNamed:thumbImageName]);
    NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:fullImageName]);
    site.imageThumb = imageThumbData;
    
    SiteDetail *siteDetails = [NSEntityDescription insertNewObjectForEntityForName:@"SiteDetail" inManagedObjectContext:context];
    siteDetails.image = imageData;
    site.detail = siteDetails;
    
    site.date = [NSDate date]; 
    site.locationPosition = @"-37.812225,144.963055";
    site.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse accumsan leo eu felis pharetra ut semper ipsum pellentesque. Sed sed erat ut mi ullamcorper auctor. Nunc faucibus volutpat metus. Suspendisse quis purus at sem laoreet fringilla rhoncus sed leo. Maecenas purus odio, suscipit ac rhoncus id, ultrices eget nisl. Pellentesque tempus nisl eget leo volutpat scelerisque. Nam pretium odio vel enim adipiscing sit amet tristique nisl ultricies. \r\n \r\n Aenean et urna enim, a tincidunt dui. Curabitur rutrum ligula ut nisl viverra gravida ut et mauris. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Pellentesque suscipit lobortis auctor. Integer dignissim sem quis eros tempor et elementum leo fringilla. Duis pulvinar dictum neque, ut aliquet lacus porttitor malesuada. Vivamus sed arcu quis dolor elementum rhoncus. Nam aliquam semper diam, consequat faucibus erat varius sed. Nulla facilisi.";
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error saving: %@", [error localizedDescription]);
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                     action:nil] autorelease];
    
    NSError *error;
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Site" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    self.sites = [context executeFetchRequest:fetchRequest error:&error];
    
//    [self addDummyDataWithImage:@"melbourne1" context:context];
//    [self addDummyDataWithImage:@"melbourne2" context:context];
//    [self addDummyDataWithImage:@"melbourne3" context:context];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sites count];
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
    
    Site *site = [self.sites objectAtIndex:indexPath.row];
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:1];
    [image setImage:[UIImage imageWithData:site.imageThumb]];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:2];
    label.text = site.title;

    label = (UILabel *)[cell viewWithTag:3];
    label.text = site.locationText;
    
    label = (UILabel *)[cell viewWithTag:4];
    label.text = site.text;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    SiteDetailViewController *detailViewController = [[SiteDetailViewController alloc] initWithNibName:@"SiteDetailViewController" bundle:nil];
    detailViewController.site = [self.sites objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
     
}

- (void)dealloc {
    [_managedObjectContext release];
    [_sites release];
}

@end
