//
//  CommentViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 13/09/2012.
//
//

#import "CommentViewController.h"
#import "NSString+HTML.h"
#import "PlaceDetailFetcher.h"
#import "Comment.h"

@interface CommentViewController ()
{
    BOOL _postingComment;
}
@property (nonatomic, retain) NSMutableArray *comments;
- (void)fetchComments;
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
    [_comments release];
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
    
    _postingComment = NO;
    
    [self fetchComments];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.postButton = nil;
    self.tableView = nil;
    self.commentBox = nil;
}

#pragma mark - ui actions -

- (IBAction)postComment:(id)sender
{
    if (_postingComment) {
        return;
    }
    
    if ([self.commentBox.text stringByRemovingNewLinesAndWhitespace].length > 0) {
        
        _postingComment = YES;
        
        [PlaceDetailFetcher postCommentForPlaceID:self.placeID withComment:self.commentBox.text success:^(int commentID) {
            [self fetchComments];
            self.commentBox.text = @"";
            _postingComment = NO;
        } failure:^(NSString *error) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil message:@"There was a problem posting your comment. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] autorelease];
            [alertView show];
            _postingComment = NO;
        }];
    }
}

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

- (void)fetchComments
{
    [PlaceDetailFetcher fetchCommentsForPlaceID:self.placeID success:^(NSArray *comments){
        
        self.comments = [NSMutableArray arrayWithArray:[[comments reverseObjectEnumerator] allObjects]];
        [self.tableView reloadData];
        
        if (self.comments.count > 0) {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.comments.count - 1) inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        
    } failure:^(NSString *error) {
        UIAlertView *alertview = [[[UIAlertView alloc] initWithTitle:@"Problem fetching comments" message:@"There was an issue fetching the comments. Please try again later." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] autorelease];
        [alertview show];
    }];
}

#define CELL_LABEL_WIDTH 307
#define CELL_FONT_SIZE 14.0

#pragma mark - tableview delegates / datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *comment = [self.comments objectAtIndex:indexPath.row];
    CGSize commentSize = [comment.text sizeWithFont:[UIFont systemFontOfSize:CELL_FONT_SIZE] constrainedToSize:CGSizeMake(CELL_LABEL_WIDTH, 20000.0f) lineBreakMode:UILineBreakModeWordWrap];
    int height = commentSize.height + 25;
    return height < 48 ? 48 : height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
}

#define CELL_REUSE_ID @"commentcell"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CELL_REUSE_ID];
    
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
        cell = self.commentCell;
        self.commentCell = nil;
    }
    
    UILabel *username = (UILabel *)[cell viewWithTag:1];
    UILabel *time = (UILabel *)[cell viewWithTag:2];
    UILabel *text = (UILabel *)[cell viewWithTag:3];
    
    Comment *comment = [self.comments objectAtIndex:indexPath.row];
    
    username.text = comment.name;
    time.text = comment.timeSinceText;
    text.text = comment.text;
    
    //resize comment label
    CGSize commentSize = [comment.text sizeWithFont:[UIFont systemFontOfSize:CELL_FONT_SIZE] constrainedToSize:CGSizeMake(CELL_LABEL_WIDTH, 20000.0f) lineBreakMode:UILineBreakModeWordWrap];
    text.frame = CGRectMake(text.frame.origin.x, text.frame.origin.y, commentSize.width, commentSize.height);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
