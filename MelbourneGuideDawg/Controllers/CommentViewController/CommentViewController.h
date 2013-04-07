//
//  CommentViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 13/09/2012.
//
//

#import <UIKit/UIKit.h>

@protocol CommentViewControllerDelegate <NSObject>
- (void)commmentCountUpdated:(int)count;
@end

@interface CommentViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, weak) id<CommentViewControllerDelegate> delegate;
@property (nonatomic, assign) int placeID;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, weak) IBOutlet UITableViewCell *commentCell;
@property (nonatomic, strong) IBOutlet UIButton *postButton;
@property (nonatomic, strong) IBOutlet UITextField *commentBox;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *usernameView;
@property (nonatomic, strong) IBOutlet UITextField *usernameTextField;

- (IBAction)postComment:(id)sender;
- (IBAction)textFieldTextChanged:(id)sender;

@end
