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

@interface SubmissionViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UITextViewDelegate, CategoryViewControllerProtocol>

@property (nonatomic, assign) IBOutlet UITableViewCell *tableCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *locatingCell;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar *keyboardInputAccessoryView;
@property (nonatomic, retain) UIGestureRecognizer *tapRecognizer;

- (IBAction)dismissKeyboard:(id)sender;

@end
