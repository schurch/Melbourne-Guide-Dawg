//
//  UIViewController+UIViewController_Utils.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 18/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+Extras.h"

@implementation UIViewController(Extras)

+ (UINavigationController *)createNavControllerWithRootViewController:(UIViewController *)rootViewController 
{
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
//    navigationController.navigationBarHidden = YES;    
    navigationController.navigationBar.tintColor = [UIColor colorWithRed:(0.0/255.0 ) green:(0.0/255.0) blue:(0.0/255.0) alpha:1.0];
    return navigationController;
}

@end
