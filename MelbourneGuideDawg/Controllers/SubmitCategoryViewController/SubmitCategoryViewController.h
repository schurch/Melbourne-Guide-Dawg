//
//  SubmitCategoryViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 12/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "Category.h"

@protocol CategoryViewControllerProtocol <NSObject>
- (void)selectedCategory:(Category *)category;
@end

@interface SubmitCategoryViewController : UIViewController

@property (nonatomic, weak) id<CategoryViewControllerProtocol> delegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *categories;

@end
