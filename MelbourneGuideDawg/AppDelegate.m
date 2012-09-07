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
#import "UIViewController+Extras.h"
#import "SubmissionViewController.h"
#import "UIImage+Extras.h"
#import "MBProgressHUD.h"

//Get flurry to report uncaught exceptions
void uncaughtExceptionHandler(NSException *exception);
void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAnalytics logError:@"ERROR: Uncaught Exception." message:@"Application crash occured!" exception:exception];
}

//add custom nav bar for ios 4
@implementation UINavigationBar (UINavigationBarCategory)

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    UIImage *img  = [UIImage imageNamed: @"nav-bar.png"];
    [img drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];    
}

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

#pragma mark - init / dealloc 

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

#pragma mark - application delegate -

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //flurry init
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [FlurryAnalytics startSession:@"3BPCNKEM1QTCUMTC9R2V"];
    
    application.statusBarHidden = NO;
    
    //add custom navbar for ios 5
    if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-bar.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    HomeViewController *homeViewController = [[[HomeViewController alloc] initWithNibName:@"HomeView" bundle:nil] autorelease];

    CategoryViewController *categoryViewController = [[[CategoryViewController alloc] initWithNibName:@"CategoryView" bundle:nil] autorelease];
    UINavigationController *placesNavigationController = [[[UINavigationController alloc] initWithRootViewController:categoryViewController] autorelease];    
    placesNavigationController.navigationBar.tintColor = [UIColor blackColor];
    
    MapViewController *mapViewController = [[[MapViewController alloc] initWithNibName:@"MapView" bundle:nil] autorelease];
    UINavigationController *mapNavigationController = [[[UINavigationController alloc] initWithRootViewController:mapViewController] autorelease];
    
    
    SubmissionViewController *submissionViewController = [[[SubmissionViewController alloc] initWithNibName:@"SubmissionView" bundle:nil] autorelease];
    UINavigationController *submissionNavController = [[UINavigationController alloc] initWithRootViewController:submissionViewController];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:homeViewController, placesNavigationController, mapNavigationController, submissionNavController, nil];
    self.tabBarController.delegate = self;
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - methods -

- (void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        SubmissionViewController *submissionViewController = [((UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:3]).viewControllers objectAtIndex:0];
        [submissionViewController dismissModalViewControllerAnimated:YES];
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        [submissionViewController presentModalViewController:imagePicker animated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"This operation is not supported on this device." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - tabbar controller delegates -

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *rootController = [[((UINavigationController *)viewController) viewControllers] objectAtIndex:0];
        if ([rootController isKindOfClass:[SubmissionViewController class]]) {
            SubmissionViewController *submissionController = (SubmissionViewController *)rootController;
            
            if (submissionController.photo) {
                return YES;
            }
            
            [self takePhoto];
        
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - image picker deleagates -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.labelText = @"Processing image..";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [picker release];
        
        UIImage *resizedImage = nil;
        if (image.size.width > image.size.height) {
            //landscape
            resizedImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(864, 640)];
        } else {
            //portrait
            resizedImage = [UIImage imageWithImage:image scaledToSize:CGSizeMake(640, 864)];
        }
        
        UIImage *thumbnailImage = [image imageByScalingAndCroppingForSize:CGSizeMake(148, 150)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.window animated:YES];
            SubmissionViewController *submissionViewController = [((UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:3]).viewControllers objectAtIndex:0];
            submissionViewController.photo = resizedImage;
            submissionViewController.photoThumbnail = thumbnailImage;
            [submissionViewController dismissModalViewControllerAnimated:YES];
            [submissionViewController fetchLocation];
            [submissionViewController resetView];
        });
    });
    
    [self.tabBarController setSelectedIndex:3];
}

@end
