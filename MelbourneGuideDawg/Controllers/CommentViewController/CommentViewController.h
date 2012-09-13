//
//  CommentViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 13/09/2012.
//
//

#import <UIKit/UIKit.h>

@interface CommentViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, assign) IBOutlet UITableViewCell *commentCell;
@property (nonatomic, retain) IBOutlet UIButton *postButton;
@property (nonatomic, retain) IBOutlet UITextField *commentBox;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (IBAction)textFieldTextChanged:(id)sender;

@end
