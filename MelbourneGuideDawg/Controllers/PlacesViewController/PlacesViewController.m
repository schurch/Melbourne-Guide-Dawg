//
//  SitesViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlacesViewController.h"
#import "Place.h"
#import "Place+Extensions.h"
#import "PlaceDetailViewController.h"

@interface PlacesViewController()
- (void)refreshView;
@end

@implementation PlacesViewController


#pragma mark - Init -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)  {
    }
    return self;
}

#pragma mark - memory management -


#pragma mark - View lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [Utils generateButtonItemWithImageName:@"back-btn.png" target:self selector:@selector(back:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.tableView = nil;
    self.tableViewCell = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshView];
}

#pragma mark - Methods -

- (void)back:(id)sender 
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshView
{
    self.title = self.category.name;
    [self.tableView reloadData];
}

#pragma mark - Table view data source delegates -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SiteIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"PlaceCell" owner:self options:nil];
        cell = self.tableViewCell;
        self.tableViewCell = nil;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    Place *place = [self.places objectAtIndex:indexPath.row];
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:1];
    NSString *imageFilePath = [[place imagePathForType:kPlaceImageTypeSmall] path];
    [image setImage:[UIImage imageWithContentsOfFile:imageFilePath]];
    
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:2];
    label.text = place.name;

    label = (UILabel *)[cell viewWithTag:3];
    label.text = place.address;
    
    label = (UILabel *)[cell viewWithTag:4];
    label.text = place.text;
    
    return cell;
}

#pragma mark - Table view delegates - 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    PlaceDetailViewController *placeDetailViewController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
    placeDetailViewController.place = [self.places objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:placeDetailViewController animated:YES];
}

@end
