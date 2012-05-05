//
//  AppDelegate.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "HomeViewController.h"
#import "CategoryViewController.h"
#import "MapViewController.h"
#import "UIViewController+Utils.h"

@implementation UINavigationBar (UINavigationBarCategory)

- (void)drawRect:(CGRect)rect {
    UIImage *img  = [UIImage imageNamed: @"nav-bar.png"];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];    
}

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.statusBarHidden = NO;
    
    if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-bar.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    HomeViewController *homeViewController = [[[HomeViewController alloc] initWithNibName:@"HomeView" bundle:nil] autorelease];

    CategoryViewController *categoryViewController = [[[CategoryViewController alloc] initWithNibName:@"CategoryView" bundle:nil] autorelease];
    UINavigationController *placesNavigationController = [[[UINavigationController alloc] initWithRootViewController:categoryViewController] autorelease];    
    placesNavigationController.navigationBar.tintColor = [UIColor blackColor];
    
    MapViewController *mapViewController = [[[MapViewController alloc] initWithNibName:@"MapView" bundle:nil] autorelease];
    UINavigationController *mapNavigationController = [UIViewController createNavControllerWithRootViewController:mapViewController];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:homeViewController, placesNavigationController, mapNavigationController, nil];
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
