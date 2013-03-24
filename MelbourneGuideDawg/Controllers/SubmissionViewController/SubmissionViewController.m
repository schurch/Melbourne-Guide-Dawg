//
//  SubmissionViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 12/08/2012.
//
//

#import <AddressBookUI/AddressBookUI.h>
#import <QuartzCore/QuartzCore.h>
#import "SubmissionViewController.h"
#import "AppDelegate.h"
#import "NSString+HTML.h"
#import "Category.h"
#import "Place.h"
#import "Place+Extensions.h"
#import "NSManagedObject+Entity.h"
#import "MBProgressHUD.h"
#import "FoursquareVenue.h"

#define TITLE_TEXTFIELD_TAG 100
#define WEBSITE_TEXTFIELD_TAG 101
#define ALERTVIEW_SUCCESS_TAG 200
#define CATEGORY_DEFAULT_TEXT @"Category"

@interface SubmissionViewController ()
@property (nonatomic, retain) Category *category;
- (void)resetLocatingCell;
- (void)showLocationCellError;
- (void)setPostEnabledState;
- (BOOL)validateFields;
@end

@implementation SubmissionViewController

#pragma mark - init / dealloc -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Submit", @"Submit");
        self.tabBarItem.image = [UIImage imageNamed:@"submit-tab.png"];
    }
    return self;
}

- (void)dealloc
{
    [_category release];
    [_locatingCell release];
    [_mainBodyTextCell release];
    [_keyboardInputAccessoryView release];
    [_tapRecognizer release];
    [_submissionTitle release];
    [_website release];
    [_text release];
    [_address release];
    [_photo release];
    [_photoThumbnail release];
    
    [super dealloc];
}

#pragma mark - view lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tapRecognizer = [[[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)] autorelease];
    
    [[NSBundle mainBundle] loadNibNamed:@"LocationCell" owner:self options:nil];
    [[NSBundle mainBundle] loadNibNamed:@"LargeTextCell" owner:self options:nil];
    
    self.navigationItem.leftBarButtonItem = [Utils generateButtonItemWithImageName:@"back-btn.png" target:self selector:@selector(takePhoto:)];
    self.navigationItem.rightBarButtonItem = [Utils generateButtonItemWithImageName:@"post-btn.png" target:self selector:@selector(post:)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.tableCell = nil;
    self.locatingCell = nil;
    self.mainBodyTextCell = nil;
    self.tableView = nil;
    self.keyboardInputAccessoryView = nil;
    
    //if view is unloaded for whatever reason, reset everything
    self.photo = nil;
    self.photoThumbnail = nil;
    [self resetView];
}

#pragma mark - Methods -

- (void)setPostEnabledState
{
    BOOL titleSet = ![[self.submissionTitle stringByRemovingNewLinesAndWhitespace] isEqualToString:@""];
    BOOL categorySet = self.category != nil;
    BOOL addressSet = ![[self.address stringByRemovingNewLinesAndWhitespace] isEqualToString:@""];
    BOOL textSet = ![[self.text stringByRemovingNewLinesAndWhitespace] isEqualToString:@""];
    
    if (titleSet && categorySet && addressSet && textSet) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)resetView
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.submissionTitle = @"";
    self.category = nil;
    self.website = @"http://";
    self.text = @"";
    
    UILabel *placeholderText = (UILabel *)[self.mainBodyTextCell viewWithTag:3];
    placeholderText.hidden = NO;
    
    [self resetLocatingCell];
    [self.tableView reloadData];
}

- (void)fetchLocation
{
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:NO];
    [self.view removeGestureRecognizer:self.tapRecognizer];
    
    if (self.tableView.contentInset.bottom == 216) {
        self.tableView.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (void)resetLocatingCell
{
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.locatingCell viewWithTag:1];
    UILabel *cellLabel = (UILabel *)[self.locatingCell viewWithTag:2];
    UIImageView *checkCrossImage = (UIImageView *)[self.locatingCell viewWithTag:3];
    
    [activityIndicator startAnimating];
    cellLabel.text = @"Geotagging...";
    cellLabel.textColor = [UIColor lightGrayColor];
    checkCrossImage.hidden = YES;
    
    [self setPostEnabledState];
}

- (void)showLocationCellError
{
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.locatingCell viewWithTag:1];
    UILabel *cellLabel = (UILabel *)[self.locatingCell viewWithTag:2];
    UIImageView *checkCrossImage = (UIImageView *)[self.locatingCell viewWithTag:3];
    
    [activityIndicator stopAnimating];
    
    cellLabel.text = @"There was an error fetching the address.";
    checkCrossImage.image = [UIImage imageNamed:@"red-cross.png"];
    checkCrossImage.hidden = NO;
    
    [self setPostEnabledState];
}

- (void)updateAddressCellWithAddress:(NSString *)address
{
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.locatingCell viewWithTag:1];
    [activityIndicator stopAnimating];
    
    UILabel *cellLabel = (UILabel *)[self.locatingCell viewWithTag:2];
    UIImageView *checkCrossImage = (UIImageView *)[self.locatingCell viewWithTag:3];
    
    checkCrossImage.image = [UIImage imageNamed:@"green-check.png"];
    checkCrossImage.hidden = NO;
    
    cellLabel.textColor = [UIColor blackColor];
    cellLabel.text = address;
}

- (IBAction)post:(id)sender
{
    NSLog(@"Post..");
    
    [self dismissKeyboard:nil];
    
    BOOL valid = [self validateFields];
    if (!valid) {
        return;
    }
    
    self.view.window.userInteractionEnabled = NO;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Submitting..";
    
    NSDictionary *details =
    @{
        @"place[name]" : self.submissionTitle,
        @"place[lat]" : [NSNumber numberWithDouble:self.coords.latitude],
        @"place[lng]" : [NSNumber numberWithDouble:self.coords.longitude],
        @"place[address]" : self.address,
        @"place[text]" : self.text,
        @"place[category_id]" : self.category.categoryId,
        @"place[url]" : self.website,
        @"place[device_id]" : [Utils deviceID]
    };
    
    [Place submitWithDetails:details image:self.photo success:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.view.window.userInteractionEnabled = YES;
        UIAlertView *alertview = [[[UIAlertView alloc] initWithTitle:@"Thank you" message:@"Thank you for your submission. All details need to be reviewed and approved before being added to the app." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
        alertview.tag = ALERTVIEW_SUCCESS_TAG;
        [alertview show];
    } failure:^(NSString *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.view.window.userInteractionEnabled = YES;
        UIAlertView *alertview = [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error submitting your place. Please try again later." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
        [alertview show];
    }];
}

- (IBAction)takePhoto:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate takePhoto];
}

- (BOOL)validateFields
{
    BOOL titleSet = self.submissionTitle && ![[self.submissionTitle stringByRemovingNewLinesAndWhitespace] isEqualToString:@""];
    if (!titleSet) {
        UIAlertView *alertview = [[[UIAlertView alloc] initWithTitle:@"Title" message:@"Please enter a title." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
        [alertview show];
        return NO;
    }
    
    BOOL categorySet = self.category != nil;
    if (!categorySet) {
        UIAlertView *alertview = [[[UIAlertView alloc] initWithTitle:@"Category" message:@"Please select a category." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
        [alertview show];
        return NO;
    }
    
    BOOL addressSet = self.address && ![[self.address stringByRemovingNewLinesAndWhitespace] isEqualToString:@""];
    if (!addressSet) {
        UIAlertView *alertview = [[[UIAlertView alloc] initWithTitle:@"Address" message:@"The address cannot be found. Please make sure you have location services enabled and an active internet connection." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
        [alertview show];
        return NO;
    }
    
    BOOL textSet = self.text && ![[self.text stringByRemovingNewLinesAndWhitespace] isEqualToString:@""];
    if (!textSet) {
        UIAlertView *alertview = [[[UIAlertView alloc] initWithTitle:@"Text" message:@"Please enter some text." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
        [alertview show];
        return NO;
    }
    
    return YES;
}

- (void)refresh
{
    [self dismissKeyboard:nil];
    [self resetLocatingCell];
    [self fetchLocation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 1;
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [[NSBundle mainBundle] loadNibNamed:@"TextCell" owner:self options:nil];
            cell = self.tableCell;
            self.tableCell = nil;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UITextField *textField = (UITextField *)[cell viewWithTag:1];
            textField.placeholder = @"Title";
            textField.delegate = self;
            textField.returnKeyType = UIReturnKeyDone;
            textField.text = self.submissionTitle;
            textField.tag = TITLE_TEXTFIELD_TAG;
            textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        } else if (indexPath.row == 1) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
            if (!self.category) {
                cell.textLabel.font = [UIFont systemFontOfSize:16];
                cell.textLabel.textColor = [UIColor lightGrayColor];
            }
            cell.textLabel.text = self.category ? self.category.name : CATEGORY_DEFAULT_TEXT;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 2) {
            [[NSBundle mainBundle] loadNibNamed:@"TextCell" owner:self options:nil];
            cell = self.tableCell;
            self.tableCell = nil;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UITextField *textField = (UITextField *)[cell viewWithTag:1];
            textField.placeholder = @"Website";
            textField.delegate = self;
            textField.keyboardType = UIKeyboardTypeURL;
            textField.returnKeyType = UIReturnKeyDone;
            textField.text = self.website;
            textField.tag = WEBSITE_TEXTFIELD_TAG;
        }
    } else if (indexPath.section == 1) {
        cell = self.locatingCell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == 2) {
        cell = self.mainBodyTextCell;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITextView *textView = (UITextView *)[cell viewWithTag:1];
        textView.delegate = self;
        textView.inputAccessoryView = self.keyboardInputAccessoryView;
        textView.text = self.text;
        
        UIImageView *thumnailImageView = (UIImageView *)[cell viewWithTag:2];        
        thumnailImageView.image = self.photoThumbnail;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0) {
        return 130;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            SubmitCategoryViewController *categoryViewController = [[[SubmitCategoryViewController alloc] initWithNibName:@"SubmitCategoryView" bundle:nil] autorelease];
            categoryViewController.delegate = self;
            [self.navigationController pushViewController:categoryViewController animated:YES];
        }
    } else if (indexPath.section == 1) {
        FoursquareViewController *foursquareViewController = [[[FoursquareViewController alloc] initWithNibName:@"FoursquareView" bundle:nil] autorelease];
        foursquareViewController.delegate = self;
        [self.navigationController pushViewController:foursquareViewController animated:YES];
    }
}

#pragma mark - Location manager delegate -

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    
    self.coords = newLocation.coordinate;
    
    CLGeocoder * geoCoder = [[[CLGeocoder alloc] init] autorelease];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if (error) {
            NSLog(@"Error occured reverse geocoding.");
            [self showLocationCellError];
            [super stopLoading];
            return;
        }
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        self.address = [[ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO) autorelease] stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
        
        [self updateAddressCellWithAddress:self.address];
        [self setPostEnabledState];
        [super stopLoading];
    }];
    
    [manager release];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error occured fetching coords.");
    [super stopLoading];
    [self showLocationCellError];
    [manager release];
}

#pragma mark - TextField delegate -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view addGestureRecognizer:self.tapRecognizer];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyboard:nil];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag == TITLE_TEXTFIELD_TAG) {
        self.submissionTitle = textField.text;
    } else if (textField.tag == WEBSITE_TEXTFIELD_TAG) {
        self.website = textField.text;
    }
    
    [self setPostEnabledState];
    
    return YES;
}

#pragma mark - TextView delegates -

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.tableView.contentInset =  UIEdgeInsetsMake(0, 0, 216, 0);
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [self.tableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textViewDidChange:(UITextView *)textView
{
    UILabel *placeholderText = (UILabel *)[self.mainBodyTextCell viewWithTag:3];
    if (textView.text.length > 0) {
        placeholderText.hidden = YES;
    } else {
        placeholderText.hidden = NO;
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.text = textView.text;
    [self setPostEnabledState];
    return YES;
}

#pragma mark - Alertview delegate -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERTVIEW_SUCCESS_TAG) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.tabImageView.image = [UIImage imageNamed:@"t-bar-1.png"];
        [self.tabBarController setSelectedIndex:0];
        self.photo = nil;
        self.photoThumbnail = nil;
        [self resetView];
    }
}

#pragma mark - Category selected delegate -

- (void)selectedCategory:(Category *)category
{
    self.category = category;
    [self.tableView reloadData];
    [self setPostEnabledState];
}

#pragma mark - scrollview delegate -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [super scrollViewWillBeginDragging:scrollView];
    
    if (scrollView == self.tableView && self.tableView.contentInset.bottom != 216) {
        [self dismissKeyboard:nil];
    }
}

#pragma mark - foursquare viewcontroller delegate -

- (void)foursquareViewController:(FoursquareViewController *)foursqaureViewController
        didSelectFoursquareVenue:(FoursquareVenue *)foursquareVenue
{
    self.coords = foursquareVenue.locationCoords;
    self.submissionTitle = foursquareVenue.name;
    self.website = [foursquareVenue.venueURL absoluteString];
    self.address = [foursquareVenue fullAddress];
    
    [self updateAddressCellWithAddress:self.address];
    
    [self.tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
