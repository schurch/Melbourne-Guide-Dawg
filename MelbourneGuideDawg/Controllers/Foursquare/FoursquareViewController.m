//
//  FoursquareViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 24/03/2013.
//
//

#import "FoursquareViewController.h"
#import "Foursquare2.h"
#import "FoursquareVenue.h"

typedef enum {
    FoursquareViewControllerModeLoading,
    FoursquareViewControllerModeDisplayingResults,
    FoursquareViewControllerModeDisplayingError
} FoursquareViewControllerMode;

@interface FoursquareViewController ()
@property (nonatomic, assign) FoursquareViewControllerMode currentViewControllerMode;
@property (nonatomic, retain) NSMutableArray *foursquareLocations;
@property (nonatomic, retain) NSString *errorMessage;
- (void)fetchNearbyLocations;
@end

@implementation FoursquareViewController

#pragma mark - init / dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Locations";
    }
    return self;
}

- (void)dealloc
{
    [_tableView release];
    [_poweredByFoursquareCell release];
    [_foursquareLocations release];
    [_errorMessage release];
    
    [super dealloc];
}

#pragma mark - view lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [Utils generateButtonItemWithImageName:@"back-btn.png" target:self selector:@selector(back:)];
    
    [[NSBundle mainBundle] loadNibNamed:@"PoweredByFoursquareCell" owner:self options:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.tableView = nil;
    self.poweredByFoursquareCell = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchNearbyLocations];
}

#pragma mark - private methods -

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fetchNearbyLocations
{
    self.currentViewControllerMode = FoursquareViewControllerModeLoading;
    self.foursquareLocations = [[[NSMutableArray alloc] init] autorelease];
    
    UIActivityIndicatorView * activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    UIBarButtonItem *loadingViewItem = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
    [activityView startAnimating];
    
    UIBarButtonItem *fixedSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil];
    [fixedSpaceItem setWidth:8];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixedSpaceItem, loadingViewItem, nil];
    
    [self.tableView reloadData];
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.currentViewControllerMode == FoursquareViewControllerModeLoading) {
        return 2;
    } else if (self.currentViewControllerMode == FoursquareViewControllerModeDisplayingError) {
        return 2;
    } else {
        //-- Locations + 'Powered by Foursquare' cell
        return [self.foursquareLocations count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentViewControllerMode == FoursquareViewControllerModeLoading) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.text = @"Searching for nearby locations...";
            return cell;
        }
        else {
            return self.poweredByFoursquareCell;
        }
    } else if (self.currentViewControllerMode == FoursquareViewControllerModeDisplayingError) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.text = self.errorMessage;
            return cell;
        }
        else {
            return self.poweredByFoursquareCell;
        }
    } else {
        int poweredByFoursquareCellRow = [self.foursquareLocations count];
        if (indexPath.row == poweredByFoursquareCellRow) {
            return self.poweredByFoursquareCell;
        } else {
            //-- Return normal location row
            
            static NSString *locationCellIdentifier = @"LocationCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:locationCellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:locationCellIdentifier] autorelease];
                cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            }
            
            FoursquareVenue *venue = self.foursquareLocations[indexPath.row];
            cell.textLabel.text = venue.name;
            cell.detailTextLabel.text = [venue fullAddress];
            
            return cell;
        }
    }
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentViewControllerMode == FoursquareViewControllerModeLoading) {
        return;
    }
    
    int poweredByFoursquareCellRow = [self.foursquareLocations count];
    if (indexPath.row == poweredByFoursquareCellRow) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(foursquareViewController:didSelectFoursquareVenue:)]) {
        [self.delegate foursquareViewController:self didSelectFoursquareVenue:self.foursquareLocations[indexPath.row]];
    }
}

#pragma mark - Location manager delegate -

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    
    [Foursquare2 searchVenuesNearByLatitude:@(newLocation.coordinate.latitude)
								  longitude:@(newLocation.coordinate.longitude)
								 accuracyLL:nil
								   altitude:nil
								accuracyAlt:nil
									  query:nil
									  limit:nil
									 intent:intentCheckin
                                     radius:@(500)
								   callback:^(BOOL success, id result){
									   if (success) {
                                           self.currentViewControllerMode = FoursquareViewControllerModeDisplayingResults;
                                           
                                           //-- Build array of venues
                                           NSArray *venuesData = [result valueForKeyPath:@"response.venues"];
                                           for (NSDictionary *venueData in venuesData) {
                                               FoursquareVenue *venue = [[[FoursquareVenue alloc] initWithDictionary:venueData] autorelease];
                                               [self.foursquareLocations addObject:venue];
                                           }
                                           
                                           [self.tableView reloadData];
                                           
                                           //-- Reset location button
                                           self.navigationItem.rightBarButtonItems = @[[Utils generateButtonItemWithImageName:@"locate-btn.png" target:self selector:@selector(fetchNearbyLocations)]];
									   }
                                       else {
                                           self.currentViewControllerMode = FoursquareViewControllerModeDisplayingError;
                                           self.errorMessage = @"Unable to fetch locations.";
                                           [self.tableView reloadData];
                                           
                                           //-- Reset location button
                                           self.navigationItem.rightBarButtonItems = @[[Utils generateButtonItemWithImageName:@"locate-btn.png" target:self selector:@selector(fetchNearbyLocations)]];
                                       }
								   }];
    [manager release];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Location services are not enabled. To enable this feature go to iOS Settings > Privacy > Location Services and enable them for the 'Melbourne' app." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil] autorelease];
    [alertView show];
    
    self.currentViewControllerMode = FoursquareViewControllerModeDisplayingError;
    self.errorMessage = @"Location servies are not enabled.";
    [self.tableView reloadData];
    
    //-- Reset location button
    self.navigationItem.rightBarButtonItems = @[[Utils generateButtonItemWithImageName:@"locate-btn.png" target:self selector:@selector(fetchNearbyLocations)]];
    
    [manager release];
}

@end