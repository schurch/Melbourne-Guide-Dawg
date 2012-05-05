//
//  MapViewController.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "Place.h"
#import "Place+Extensions.h"
#import "PlaceDetailViewController.h"

@interface MapViewController()
- (void)resetMapLocationWithAnimation:(BOOL)animate location:(CLLocationCoordinate2D)location zoom:(double)zoom;
@end

@implementation MapViewController

@synthesize selectedPlaceId = _selectedPlaceId;
@synthesize map = _map;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize places = _places;
@synthesize location = _location;

#pragma mark - Init -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageNamed:@"map_tab.png"];
        self.managedObjectContext = [NSManagedObjectContext sharedInstance];
        
        _animatingToAnnotation = NO;
    }
    return self;
}

#pragma mark - Memory management -

- (void)dealloc 
{
    [_selectedPlaceId release];
    [_map release];
    [_managedObjectContext release];
    [_places release];
    [super dealloc];
}

#pragma mark - Methods - 

- (void)resetMapLocationWithAnimation:(BOOL)animate location:(CLLocationCoordinate2D)location zoom:(double)zoom 
{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, zoom * METERS_PER_MILE, zoom * METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [self.map regionThatFits:viewRegion];    
    [self.map setRegion:adjustedRegion animated:animate];
}

- (void)zoomToSite 
{
    if (self.selectedPlaceId && self.map.annotations && (self.map.annotations.count > 0)) 
    {
        _animatingToAnnotation = YES;
        [self resetMapLocationWithAnimation:YES location:self.location zoom:0.2];   
    }
}

#pragma mark - View lifecycle -

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [self resetMapLocationWithAnimation:NO location:CLLocationCoordinate2DMake(-37.812225, 144.963055) zoom:2.0];
    
    self.places = [Place allPlaces];
    for (Place *place in self.places) 
    {
        [self.map addAnnotation:place];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Map view delegates

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation 
{
    
    static NSString *identifier = @"SiteLocation";   
    if ([annotation isKindOfClass:[Place class]]) 
    {        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.map dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        Place *place = (Place *)annotation;
        
        if (annotationView == nil) 
        {
            annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
            
            UIButton* rightButton = [UIButton buttonWithType:
                                     UIButtonTypeDetailDisclosure];
            annotationView.rightCalloutAccessoryView = rightButton;
            
            
            UIImageView *thumbImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[place imagePathForType:kPlaceImageTypeCell]]];
            thumbImageView.frame = CGRectMake(0,0,30,30);
            annotationView.leftCalloutAccessoryView = thumbImageView;
            [thumbImageView release];
        } 
        else 
        {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        
        return annotationView;
    }
    
    return nil;    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control 
{    
    if ([view.annotation isKindOfClass:[Place class]]) 
    {
        PlaceDetailViewController *placeDetailViewController = [[PlaceDetailViewController alloc] initWithNibName:@"PlaceDetailView" bundle:nil];
        placeDetailViewController.place = view.annotation;
        [self.navigationController pushViewController:placeDetailViewController animated:YES];
        [placeDetailViewController release];     
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    [self zoomToSite];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated 
{
    if (_animatingToAnnotation) {
        for (Place *place in self.places) {
            if ([place.placeId intValue] == [self.selectedPlaceId intValue]) {
                [self.map selectAnnotation:place animated:YES];
            }
        }
        
        _animatingToAnnotation = NO;
        self.selectedPlaceId = nil;
    }
}

@end
