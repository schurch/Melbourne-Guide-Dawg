//
//  MapViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "Site.h"
#import "Site+Extensions.h"
#import "SiteDetailViewController.h"

@implementation MapViewController

@synthesize map = _map;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize sites = _sites;
@synthesize location = _location;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageNamed:@"map_tab"];
    }
    return self;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString *identifier = @"SiteLocation";   
    if ([annotation isKindOfClass:[Site class]]) {        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.map dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        Site *site = (Site *)annotation;
        
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            
            UIButton* rightButton = [UIButton buttonWithType:
                                     UIButtonTypeDetailDisclosure];
            annotationView.rightCalloutAccessoryView = rightButton;
            
            
            UIImageView *thumbImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:site.imageThumbData]];
            thumbImageView.frame = CGRectMake(0,0,31,31); // Change the size of the image to fit the callout
            annotationView.leftCalloutAccessoryView = thumbImageView;
            [thumbImageView release];
            thumbImageView = nil;
            
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        
        return annotationView;
    }
    
    return nil;    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if ([view.annotation isKindOfClass:[Site class]]) {
        SiteDetailViewController *detailViewController = [[SiteDetailViewController alloc] initWithNibName:@"SiteDetailViewController" bundle:nil];
        detailViewController.site = view.annotation;
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];     
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)resetMapLocationWithAnimation:(BOOL)animate location:(CLLocationCoordinate2D)location zoom:(double)zoom {
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, zoom * METERS_PER_MILE, zoom * METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [self.map regionThatFits:viewRegion];    
    [self.map setRegion:adjustedRegion animated:animate];
}

- (void)zoomToSite {
    if (self.location.latitude != 0 && self.location.longitude != 0) {
        [self resetMapLocationWithAnimation:YES location:self.location zoom:0.2];   
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self resetMapLocationWithAnimation:NO location:CLLocationCoordinate2DMake(-37.812225, 144.963055) zoom:2.0];
    
    NSError *error;
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Site" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    self.sites = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    
    for (Site *site in self.sites) {
        [self.map addAnnotation:site];
    }
    
    [self zoomToSite];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_map release];
    _map = nil;
    [_managedObjectContext release];
    _managedObjectContext = nil;
    [super dealloc];
}

@end
