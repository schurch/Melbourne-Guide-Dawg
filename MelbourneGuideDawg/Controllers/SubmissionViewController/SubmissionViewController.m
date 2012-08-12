//
//  SubmissionViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 12/08/2012.
//
//

#import "SubmissionViewController.h"
#import <AddressBookUI/AddressBookUI.h>

@interface SubmissionViewController ()
@property (nonatomic, retain) NSString *category;
- (void)resetLocatingCell;
- (void)showLocationCellError;
@end

@implementation SubmissionViewController

@synthesize category = _category;
@synthesize tableCell = _tableCell;
@synthesize locatingCell = _locatingCell;
@synthesize tableView = _tableView;
@synthesize tapRecognizer = _tapRecognizer;
@synthesize keyboardInputAccessoryView = _keyboardInputAccessoryView;


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
    [_tableView release];
    [_keyboardInputAccessoryView release];
    [_tapRecognizer release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    
    [[NSBundle mainBundle] loadNibNamed:@"LocationCell" owner:self options:nil];
    
    self.category = @"Category";
}

- (void)viewDidAppear:(BOOL)animated
{
    [self resetLocatingCell];
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.tableCell = nil;
    self.locatingCell = nil;
    self.tableView = nil;
    self.keyboardInputAccessoryView = nil;
}

#pragma mark - Methods -

- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:NO];
    [self.view removeGestureRecognizer:self.tapRecognizer];
    self.tableView.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0);
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
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
}

- (void)showLocationCellError
{
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.locatingCell viewWithTag:1];
    UILabel *cellLabel = (UILabel *)[self.locatingCell viewWithTag:2];
    UIImageView *checkCrossImage = (UIImageView *)[self.locatingCell viewWithTag:3];
    
    [activityIndicator stopAnimating];
    
    cellLabel.text = @"There was an error fetching the address.";
    checkCrossImage.image = [UIImage imageNamed:@"red-cross.png"];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && indexPath.row == 0) {
        return 130;
    } else {
        return 44;
    }
}

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
        } else if (indexPath.row == 1) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text = self.category;
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
        }
    } else if (indexPath.section == 1) {
        cell = self.locatingCell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (indexPath.section == 2) {
        [[NSBundle mainBundle] loadNibNamed:@"LargeTextCell" owner:self options:nil];
        cell = self.tableCell;
        self.tableCell = nil;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UITextView *textView = (UITextView *)[cell viewWithTag:1];
        textView.delegate = self;
        textView.inputAccessoryView = self.keyboardInputAccessoryView;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        SubmitCategoryViewController *categoryViewController = [[[SubmitCategoryViewController alloc] initWithNibName:@"SubmitCategoryView" bundle:nil] autorelease];
        categoryViewController.delegate = self;
        [self.navigationController pushViewController:categoryViewController animated:YES];
    }

}

#pragma mark - TextField delegate -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view addGestureRecognizer:self.tapRecognizer];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Location manager delegate -

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if (error) {
            NSLog(@"Error occured reverse geocoding.");
            [self showLocationCellError];
            return;
        }
        
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.locatingCell viewWithTag:1];
        UILabel *cellLabel = (UILabel *)[self.locatingCell viewWithTag:2];
        UIImageView *checkCrossImage = (UIImageView *)[self.locatingCell viewWithTag:3];
        
        [activityIndicator stopAnimating];
        checkCrossImage.image = [UIImage imageNamed:@"green-check.png"];
        checkCrossImage.hidden = NO;
        
        cellLabel.textColor = [UIColor blackColor];
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        cellLabel.text = [ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO) stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
    }];
    
    [manager release];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error occured fetching coords.");
    [self showLocationCellError];
    [manager release];
}

#pragma mark - TextView delegates -

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.tableView.contentInset =  UIEdgeInsetsMake(0, 0, 216, 0);
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [self.tableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - Category selected delegate -

- (void)selectedCategory:(NSString *)category
{
    self.category = category;
    [self.tableView reloadData];
}

@end
