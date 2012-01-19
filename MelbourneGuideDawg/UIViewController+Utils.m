//
//  UIViewController+UIViewController_Utils.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 18/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+Utils.h"

@implementation UIViewController(Utils)

+ (UINavigationController *)createNavControllerWithRootViewController:(UIViewController *)rootViewController {
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    navigationController.navigationBarHidden = YES;
    navigationController.navigationBar.tintColor = [UIColor colorWithRed:(64.0/255.0 ) green:(49.0/255.0) blue:(115.0/255.0) alpha:1.0];
    
    rootViewController.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                               style:UIBarButtonItemStyleBordered
                                                               target:nil
                                                               action:nil] autorelease];
    
    return [navigationController autorelease];
}

@end
