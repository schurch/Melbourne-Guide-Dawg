//
//  CategoryViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 04/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CategoryViewController.h"

@implementation CategoryViewController

@synthesize tableViewCell = _tableViewCell, managedObjectContext = _managedObjectContext, categories = _categories;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = NSLocalizedString(@"Places", @"Places");
        self.tabBarItem.image = [UIImage imageNamed:@"places_tab"];
        self.managedObjectContext = [NSManagedObjectContext sharedInstance];
    }
    return self;
}

- (void)dealloc
{
    [_managedObjectContext release];
    [_categories release];
    [super dealloc];
}

#pragma mark - View lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if DEBUG
    if ([[Category allCategories] count] == 0) 
    {
        [Category addDummyData];
        self.categories = [Category allCategories];
        [self.tableView reloadData];
    }
    else
    {
        self.categories = [Category allCategories];
    }
#endif
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = self.tableViewCell;
        self.tableViewCell = nil;
    }
    
    Category *category = [self.categories objectAtIndex:indexPath.row];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:1];
    label.text = category.name;
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //show accociated place's 
}

@end
