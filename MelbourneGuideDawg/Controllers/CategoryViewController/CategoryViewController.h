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

@interface CategoryViewController : UITableViewController

@property (nonatomic, assign) IBOutlet UITableViewCell *tableViewCell;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) PlacesViewController *placesViewController;

@end
