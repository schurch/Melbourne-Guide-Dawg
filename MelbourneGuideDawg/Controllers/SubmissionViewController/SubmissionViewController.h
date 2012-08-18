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

#import "SubmitCategoryViewController.h"

@interface SubmissionViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CategoryViewControllerProtocol>

@property (nonatomic, assign) IBOutlet UITableViewCell *tableCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *locatingCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *mainBodyTextCell;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar *keyboardInputAccessoryView;
@property (nonatomic, retain) UIGestureRecognizer *tapRecognizer;
@property (nonatomic, retain) NSString *submissionTitle;
@property (nonatomic, retain) NSString *website;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, retain) UIImage *photoThumbnail;
@property (nonatomic, assign) CLLocationCoordinate2D coords;

- (void)resetView;
- (IBAction)dismissKeyboard:(id)sender;
- (IBAction)post:(id)sender;
- (IBAction)takePhoto:(id)sender;

@end
