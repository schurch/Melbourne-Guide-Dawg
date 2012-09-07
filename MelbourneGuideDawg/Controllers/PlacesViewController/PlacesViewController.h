//
//  SitesViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"
#import "PlaceViewController.h"

@interface PlacesViewController : PlaceViewController

@property (nonatomic, retain) NSArray *places;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) IBOutlet UITableViewCell *tableViewCell;

@end
