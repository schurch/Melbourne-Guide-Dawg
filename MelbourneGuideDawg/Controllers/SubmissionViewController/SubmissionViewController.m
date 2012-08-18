//
//  SubmissionViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 12/08/2012.
//
//

#import "SubmissionViewController.h"
#import "AppDelegate.h"
#import <AddressBookUI/AddressBookUI.h>
#import "NSString+HTML.h"

#define TITLE_TEXTFIELD_TAG 100
#define WEBSITE_TEXTFIELD_TAG 101

#define CATEGORY_DEFAULT_TEXT @"Category"

@interface SubmissionViewController ()
@property (nonatomic, retain) NSString *category;
- (void)resetLocatingCell;
- (void)showLocationCellError;
- (void)setPostEnabledState;
@end

@implementation SubmissionViewController

@synthesize category = _category;
@synthesize tableCell = _tableCell;
@synthesize locatingCell = _locatingCell;
@synthesize mainBodyTextCell = _mainBodyTextCell;
@synthesize tableView = _tableView;
@synthesize tapRecognizer = _tapRecognizer;
@synthesize photo = _photo;
@synthesize photoThumbnail = _photoThumbnail;
@synthesize submissionTitle = _submissionTitle;
@synthesize website = _website;
@synthesize text = _text;
@synthesize address = _address;
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
    [_mainBodyTextCell release];
    [_tableView release];
    [_keyboardInputAccessoryView release];
    [_tapRecognizer release];
    [_photo release];
    [_photoThumbnail release];
    [_submissionTitle release];
    [_website release];
    [_text release];
    [_address release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard:)];
    
    [[NSBundle mainBundle] loadNibNamed:@"LocationCell" owner:self options:nil];
    [[NSBundle mainBundle] loadNibNamed:@"LargeTextCell" owner:self options:nil];
    
    UIImage *backButtonImage = [UIImage imageNamed:@"back-btn.png"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.0f, 0.0f, backButtonImage.size.width, backButtonImage.size.height)];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    UIImage *postButtonImage = [UIImage imageNamed:@"post-btn.png"];
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [postButton setFrame:CGRectMake(0.0f, 0.0f, postButtonImage.size.width, postButtonImage.size.height)];
    [postButton setImage:postButtonImage forState:UIControlStateNormal];
    [postButton addTarget:self action:@selector(post:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *postButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:postButton] autorelease];
    self.navigationItem.rightBarButtonItem = postButtonItem;
    postButtonItem.enabled = NO;
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
}

#pragma mark - Methods -

- (void)setPostEnabledState
{
    BOOL titleSet = ![[self.submissionTitle stringByRemovingNewLinesAndWhitespace] isEqualToString:@""];
    BOOL categorySet = ![[self.category stringByRemovingNewLinesAndWhitespace] isEqualToString:CATEGORY_DEFAULT_TEXT];
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
    self.category = CATEGORY_DEFAULT_TEXT;
    self.website = @"";
    self.text = @"";
    
    UILabel *placeholderText = (UILabel *)[self.mainBodyTextCell viewWithTag:3];
    placeholderText.hidden = NO;
    
    [self resetLocatingCell];
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    [self.tableView reloadData];
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.view endEditing:NO];
    [self.view removeGestureRecognizer:self.tapRecognizer];
    self.tableView.scrollEnabled = YES;
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
    
    [self setPostEnabledState];
}

- (IBAction)post:(id)sender
{
    NSLog(@"Post..");
}

- (IBAction)takePhoto:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate takePhoto];
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
            textField.text = self.submissionTitle;
            textField.tag = TITLE_TEXTFIELD_TAG;
            textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        SubmitCategoryViewController *categoryViewController = [[[SubmitCategoryViewController alloc] initWithNibName:@"SubmitCategoryView" bundle:nil] autorelease];
        categoryViewController.delegate = self;
        [self.navigationController pushViewController:categoryViewController animated:YES];
    }
}

#pragma mark - Location manager delegate -

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    
    self.coords = newLocation.coordinate;
    
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
        self.address = [ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO) stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
        cellLabel.text = self.address;
        
        [self setPostEnabledState];
    }];
    
    [manager release];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error occured fetching coords.");
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
    [textField resignFirstResponder];
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
    self.tableView.scrollEnabled = NO;
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

#pragma mark - Category selected delegate -

- (void)selectedCategory:(NSString *)category
{
    self.category = category;
    [self.tableView reloadData];
    [self setPostEnabledState];
}

@end
