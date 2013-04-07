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

@property (nonatomic, weak) id<FilterProtocol> delegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *categories;

@end
