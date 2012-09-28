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
- (void)reloadComments;
- (void)configure:(id)sender;
- (void)showChangeUsernameDialog:(BOOL)animated;
- (void)hideChangeUsernameDialog;
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
    [_usernameView release];
    [_usernameTextField release];
    [_loadingIndicator release];
    
    [super dealloc];
}

#pragma mark - view lifecycle -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [Utils generateButtonItemWithImageName:@"back-btn.png" target:self selector:@selector(back:)];
    self.navigationItem.rightBarButtonItem = [Utils generateButtonItemWithImageName:@"configure-btn.png" target:self selector:@selector(configure:)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.postButton.enabled = NO;
    self.commentBox.keyboardType = UIKeyboardTypeTwitter;
    
    self.usernameView.alpha = 0.0;
    
    _postingComment = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.postButton = nil;
    self.tableView = nil;
    self.commentBox = nil;
    self.usernameView = nil;
    self.usernameTextField = nil;
    self.loadingIndicator = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:kNameKeyLookup];
    if (!name) {
        [self showChangeUsernameDialog:NO];
    } else {
        [self.commentBox becomeFirstResponder];
        [self fetchComments];
    }
}

#pragma mark - ui actions -

- (IBAction)postComment:(id)sender
{
    if (_postingComment) {
        return;
    }
    
    if ([self.commentBox.text stringByRemovingNewLinesAndWhitespace].length > 0) {
        
        _postingComment = YES;
        
        self.postButton.enabled = NO;
        
        NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kNameKeyLookup];
        if (!username || [username stringByRemovingNewLinesAndWhitespace]) {
            username = kDefaultCommentUsername;
        }
        
        Comment *newComment = [[[Comment alloc] init] autorelease];
        newComment.text = self.commentBox.text;
        newComment.name = [[NSUserDefaults standardUserDefaults] stringForKey:kNameKeyLookup];
        newComment.posting = YES;
        newComment.date = [NSDate date];
        
        [self.comments addObject:newComment];
        [self reloadComments];
        
        self.commentBox.text = @"";
        
        [PlaceDetailFetcher postCommentForPlaceID:self.placeID withComment:newComment.text success:^(NSArray *comments) {
            if ([self.delegate respondsToSelector:@selector(commmentCountUpdated:)]) {
                [self.delegate commmentCountUpdated:comments.count];
            }
            self.comments = [NSMutableArray arrayWithArray:[[comments reverseObjectEnumerator] allObjects]];
            [self reloadComments];
            self.commentBox.text = @"";
            self.commentBox.enabled = YES;
            _postingComment = NO;
        } failure:^(NSString *error) {
            
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Unable to post comment" message:@"There was a problem posting your comment. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] autorelease];
            [alertView show];
            
            [self.comments removeLastObject];
            [self reloadComments];
            self.commentBox.text = newComment.text;
            self.postButton.enabled = YES;
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
    [self.loadingIndicator startAnimating];
    [PlaceDetailFetcher fetchCommentsForPlaceID:self.placeID success:^(NSArray *comments){
        [self.loadingIndicator stopAnimating];
        self.comments = [NSMutableArray arrayWithArray:[[comments reverseObjectEnumerator] allObjects]];
        [self reloadComments];
    } failure:^(NSString *error) {
        [self.loadingIndicator stopAnimating];
        UIAlertView *alertview = [[[UIAlertView alloc] initWithTitle:@"Unable to fetch comments" message:@"There was an issue fetching the comments. Please try again later." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] autorelease];
        [alertview show];
    }];
}

- (void)reloadComments
{
    [self.tableView reloadData];
    
    if (self.comments.count > 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.comments.count - 1) inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)configure:(id)sender
{
    [self showChangeUsernameDialog:YES];
}

- (void)showChangeUsernameDialog:(BOOL)animated
{
    [self.usernameTextField becomeFirstResponder];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.usernameTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kNameKeyLookup];
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.usernameView.alpha = 1.0;
        }];
    } else {
        self.usernameView.alpha = 1.0;
    }
}

- (void)hideChangeUsernameDialog
{
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.usernameView.alpha = 0.0;
        [self.commentBox becomeFirstResponder];
    } completion:^(BOOL finished) {
        //
    }];
}

#define CELL_LABEL_WIDTH 284
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
    UIActivityIndicatorView *postingCommentIndicator = (UIActivityIndicatorView *)[cell viewWithTag:4];
    
    Comment *comment = [self.comments objectAtIndex:indexPath.row];
    
    username.text = comment.name;
    time.text = comment.timeSinceText;
    text.text = comment.text;
    
    if (comment.posting) {
        [postingCommentIndicator startAnimating];
    } else {
        [postingCommentIndicator stopAnimating];
    }
    
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
#define USERNAME_MAXLENGTH 20

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (_postingComment) {
        return NO;
    }
    
    int textFieldMaxLength;
    
    if (textField.tag == 1) {
        textFieldMaxLength = COMMENT_MAXLENGTH;
    } else if (textField.tag == 2) {
        textFieldMaxLength = USERNAME_MAXLENGTH;
    }
    
    int length = [[textField.text stringByRemovingNewLinesAndWhitespace] length];
    if (length >= textFieldMaxLength && ![string isEqualToString:@""]) {
        textField.text = [textField.text substringToIndex:textFieldMaxLength];
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *name = [self.usernameTextField.text stringByRemovingNewLinesAndWhitespace];
    [[NSUserDefaults standardUserDefaults] setValue:name forKey:kNameKeyLookup];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self hideChangeUsernameDialog];
    return YES;
}

@end
