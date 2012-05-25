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

@protocol FilterProtocol <NSObject>
- (void)filterChanged:(BOOL)didFilterChange;
@end

@interface FilterViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    BOOL _filterChanged;
}

@property (nonatomic, assign) id<FilterProtocol> delegate;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *categories;

@end
