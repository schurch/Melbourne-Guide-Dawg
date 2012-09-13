//
//  CommentViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 13/09/2012.
//
//

#import "CommentViewController.h"
#import "NSString+HTML.h"

@interface CommentViewController ()

@end

@implementation CommentViewController

#pragma mark - init / dealloc -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Comments";
    }
    return self;
}

- (void)dealloc
{
    [_postButton release];
    [_tableView release];
    [_commentBox release];
    [super dealloc];
}

#pragma mark - view lifecycle -

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.commentBox becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *backButtonImage = [UIImage imageNamed:@"back-btn.png"];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0.0f, 0.0f, backButtonImage.size.width, backButtonImage.size.height)];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.postButton.enabled = NO;
    self.commentBox.keyboardType = UIKeyboardTypeTwitter;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.postButton = nil;
    self.tableView = nil;
    self.commentBox = nil;
}

#pragma mark - ui actions -

- (IBAction)textFieldTextChanged:(id)sender
{
    if ([self.commentBox.text stringByRemovingNewLinesAndWhitespace].length > 0) {
        self.postButton.enabled = YES;
    } else {
        self.postButton.enabled = NO;
    }
}

#pragma mark - methods -

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - tableview delegates / datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

#define CELL_REUSE_ID @"commentcell"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_REUSE_ID];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:CELL_REUSE_ID owner:self options:nil];
        cell = self.commentCell;
        self.commentCell = nil;
    }
    
    return cell;
}

#pragma mark - textfield delegate -

#define COMMENT_MAXLENGTH 200

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int length = [[textField.text stringByRemovingNewLinesAndWhitespace] length];
    
    if (length >= COMMENT_MAXLENGTH && ![string isEqualToString:@""]) {
        textField.text = [textField.text substringToIndex:COMMENT_MAXLENGTH];
        return NO;
    }
    
    
    return YES;
}

@end
