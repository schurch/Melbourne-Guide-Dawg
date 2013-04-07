//
//  SubmissionViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 12/08/2012.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "PullRefreshTableViewController.h"
#import "SubmitCategoryViewController.h"
#import "FoursquareViewController.h"

@interface SubmissionViewController : PullRefreshTableViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CategoryViewControllerProtocol, UIAlertViewDelegate, FoursquareViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableViewCell *tableCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *locatingCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *mainBodyTextCell;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIToolbar *keyboardInputAccessoryView;
@property (nonatomic, strong) UIGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) NSString *submissionTitle;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) UIImage *photoThumbnail;
@property (nonatomic, assign) CLLocationCoordinate2D coords;

- (void)resetView;
- (void)fetchLocation;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)post:(id)sender;
- (IBAction)takePhoto:(id)sender;

@end
