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
    
    //if using old version and data in documents, then move to cache dir
    //(Apple rejected upadate as documents folder is backed up to iCloud)
    if ([Utils downloadDataInDocuments]) {
        [Utils moveDownloadDataToCache];
    }
    
    //configure views
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    HomeViewController *homeViewController = [[HomeViewController alloc] initWithNibName:@"HomeView" bundle:nil];

    CategoryViewController *categoryViewController = [[CategoryViewController alloc] initWithNibName:@"CategoryView" bundle:nil];
    UINavigationController *placesNavigationController = [[UINavigationController alloc] initWithRootViewController:categoryViewController];    
    placesNavigationController.navigationBar.tintColor = [UIColor blackColor];
    
    MapViewController *mapViewController = [[MapViewController alloc] initWithNibName:@"MapView" bundle:nil];
    UINavigationController *mapNavigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    
    
    SubmissionViewController *submissionViewController = [[SubmissionViewController alloc] initWithNibName:@"SubmissionView" bundle:nil];
    UINavigationController *submissionNavController = [[UINavigationController alloc] initWithRootViewController:submissionViewController];
    
    
    //tabbar and customization
    self.tabImageView = [[UIImageView alloc] init];
    self.tabImageView.image = [UIImage imageNamed:@"t-bar-1.png"];
    self.tabImageView.frame = CGRectMake(0, self.window.frame.size.height - 49, 320, 49);
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:homeViewController, placesNavigationController, mapNavigationController, submissionNavController, nil];
    self.tabBarController.delegate = self;
    [self.tabBarController.view addSubview:self.tabImageView];
    
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
    }
}

#pragma mark - tabbar controller delegates -

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSUInteger index=[[tabBarController viewControllers] indexOfObject:viewController];
    
    switch (index)
    {
        case 0:
            self.tabImageView.image = [UIImage imageNamed:@"t-bar-1.png"];
            break;
        case 1:
            self.tabImageView.image = [UIImage imageNamed:@"t-bar-2.png"];
            break;
        case 2:
            self.tabImageView.image = [UIImage imageNamed:@"t-bar-3.png"];
            break;
        default:
            break;
    }
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *rootController = [[((UINavigationController *)viewController) viewControllers] objectAtIndex:0];
        if ([rootController isKindOfClass:[SubmissionViewController class]]) {
            SubmissionViewController *submissionController = (SubmissionViewController *)rootController;
            
            if (submissionController.photo) {
                self.tabImageView.image = [UIImage imageNamed:@"t-bar-4.png"];
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
    self.tabImageView.image = [UIImage imageNamed:@"t-bar-4.png"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.labelText = @"Processing image..";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
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
