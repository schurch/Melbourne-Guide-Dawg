//
//  FoursquareViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 24/03/2013.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class FoursquareVenue;

@protocol FoursquareViewControllerDelegate;

@interface FoursquareViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, weak) id<FoursquareViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITableViewCell *poweredByFoursquareCell;
@end

@protocol FoursquareViewControllerDelegate <NSObject>
@optional
- (void)foursquareViewController:(FoursquareViewController *)foursqaureViewController
        didSelectFoursquareVenue:(FoursquareVenue *)foursquareVenue;
@end
