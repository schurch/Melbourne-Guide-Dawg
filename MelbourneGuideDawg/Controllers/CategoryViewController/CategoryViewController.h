//
//  CategoryViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 04/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlacesViewController.h"
#import "Category.h"
#import "Category+Extensions.h"

@interface CategoryViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableViewCell *tableViewCell;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIImageView *pleaseSyncMessage;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) PlacesViewController *placesViewController;

@end
