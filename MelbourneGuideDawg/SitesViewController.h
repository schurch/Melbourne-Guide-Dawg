//
//  SitesViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SitesViewController : UITableViewController

@property (nonatomic, retain) NSArray *sites;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) IBOutlet UITableViewCell *tableViewCell;

@end
