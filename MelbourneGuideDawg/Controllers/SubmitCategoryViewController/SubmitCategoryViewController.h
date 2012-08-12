//
//  SubmitCategoryViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 12/08/2012.
//
//

#import <UIKit/UIKit.h>

@protocol CategoryViewControllerProtocol <NSObject>
- (void)selectedCategory:(NSString *)category;
@end

@interface SubmitCategoryViewController : UIViewController

@property (nonatomic, assign) id<CategoryViewControllerProtocol> delegate;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *categories;

@end
