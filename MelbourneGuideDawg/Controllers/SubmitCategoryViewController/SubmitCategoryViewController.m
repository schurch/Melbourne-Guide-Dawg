//
//  SubmitCategoryViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 12/08/2012.
//
//

#import "SubmitCategoryViewController.h"
#import "Category.h"
#import "Category+Extensions.h"

@implementation SubmitCategoryViewController

#pragma mark - Init / dealloc

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
}

#pragma mark - view lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [Utils generateButtonItemWithImageName:@"back-btn.png" target:self selector:@selector(back:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView)
                                                 name:kSyncCompleteNotificaton
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshView];
}

#pragma mark - methods -

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshView
{
    self.categories = [Category allCategories];
    [self.tableView reloadData];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Category *category = [self.categories objectAtIndex:indexPath.row];
    
    cell.textLabel.text = category.name;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate selectedCategory:[self.categories objectAtIndex:indexPath.row]];
}

@end
