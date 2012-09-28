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

@property (nonatomic, assign) id<CommentViewControllerDelegate> delegate;
@property (nonatomic, assign) int placeID;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, assign) IBOutlet UITableViewCell *commentCell;
@property (nonatomic, retain) IBOutlet UIButton *postButton;
@property (nonatomic, retain) IBOutlet UITextField *commentBox;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *usernameView;
@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;

- (IBAction)postComment:(id)sender;
- (IBAction)textFieldTextChanged:(id)sender;

@end
