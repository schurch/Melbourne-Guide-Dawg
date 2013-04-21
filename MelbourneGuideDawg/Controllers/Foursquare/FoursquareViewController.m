//
//  FoursquareViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 24/03/2013.
//
//

#import "FoursquareViewController.h"
#import "FoursquareVenue.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

typedef enum {
    FoursquareViewControllerModeLoading,
    FoursquareViewControllerModeDisplayingResults,
    FoursquareViewControllerModeDisplayingError
} FoursquareViewControllerMode;

@interface FoursquareViewController ()
@property (nonatomic) FoursquareViewControllerMode currentViewControllerMode;
@property (nonatomic, strong) NSMutableArray *foursquareLocations;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) CLLocationManager *locationManager;
- (void)fetchNearbyLocations;
@end

@implementation FoursquareViewController

#pragma mark - init / dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Locations";
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
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
    self.foursquareLocations = [[NSMutableArray alloc] init];
    
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem *loadingViewItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    [activityView startAnimating];
    
    UIBarButtonItem *fixedSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil];
    [fixedSpaceItem setWidth:8];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixedSpaceItem, loadingViewItem, nil];
    
    [self.tableView reloadData];
    [self.locationManager startUpdatingLocation];
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
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
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
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
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
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:locationCellIdentifier];
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

#define BASE_FOURSQUARE_URL @"https://api.foursquare.com"

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/v2/venues/search?client_id=%@&client_secret=%@&v=20130117&locale=en&ll=%@,%@&radius=500", BASE_FOURSQUARE_URL, kFoursquareOauthKey, kFoursquareOauthSecret, @(newLocation.coordinate.latitude), @(newLocation.coordinate.longitude)];
    NSURL *requestURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    
    AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        self.currentViewControllerMode = FoursquareViewControllerModeDisplayingResults;
        
        //-- Build array of venues
        NSArray *venuesData = [JSON valueForKeyPath:@"response.venues"];
        for (NSDictionary *venueData in venuesData) {
            FoursquareVenue *venue = [[FoursquareVenue alloc] initWithDictionary:venueData];
            [self.foursquareLocations addObject:venue];
        }
        
        [self.tableView reloadData];
        
        //-- Reset location button
        self.navigationItem.rightBarButtonItems = @[[Utils generateButtonItemWithImageName:@"locate-btn.png" target:self selector:@selector(fetchNearbyLocations)]];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        self.currentViewControllerMode = FoursquareViewControllerModeDisplayingError;
        self.errorMessage = @"Unable to fetch locations.";
        [self.tableView reloadData];
        
        //-- Reset location button
        self.navigationItem.rightBarButtonItems = @[[Utils generateButtonItemWithImageName:@"locate-btn.png" target:self selector:@selector(fetchNearbyLocations)]];
    }];
    
    [requestOperation start];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was a problem finding your location. To enable location services go to iOS Settings > Privacy > Location Services and enable them for the 'Melbourne' app." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alertView show];
    
    self.currentViewControllerMode = FoursquareViewControllerModeDisplayingError;
    self.errorMessage = @"Unable to find your location.";
    [self.tableView reloadData];
    
    //-- Reset location button
    self.navigationItem.rightBarButtonItems = @[[Utils generateButtonItemWithImageName:@"locate-btn.png" target:self selector:@selector(fetchNearbyLocations)]];
    
}

@end
