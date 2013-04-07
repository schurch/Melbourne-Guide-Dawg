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

@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong) Category *category;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITableViewCell *tableViewCell;

@end
