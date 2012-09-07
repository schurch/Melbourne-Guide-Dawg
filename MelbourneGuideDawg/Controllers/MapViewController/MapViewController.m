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
#import "Category.h"
#import "Category+Extensions.h"


@interface MapViewController()
@property (nonatomic, retain) FilterViewController *filterViewController;
- (void)resetMapLocationWithAnimation:(BOOL)animate location:(CLLocationCoordinate2D)location zoom:(double)zoom;
- (void)filter:(id)sender;
- (void)locate:(id)sender;
@end

@implementation MapViewController

#pragma mark - Init -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageNamed:@"map-tab.png"];
        self.managedObjectContext = [NSManagedObjectContext sharedInstance];
        
        _animatingToAnnotation = NO;
    }
    return self;
}

#pragma mark - Memory management -

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_filterViewController release];
    [_selectedPlaceId release];
    [_map release];
    [_managedObjectContext release];
    [_places release];
    
    [super dealloc];
}

#pragma mark - View lifecycle -

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    UIImage *locateBtnImage = [UIImage imageNamed:@"locate-btn.png"];
    UIButton *locateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [locateBtn setFrame:CGRectMake(0.0f, 0.0f, locateBtnImage.size.width, locateBtnImage.size.height)];
    [locateBtn setImage:locateBtnImage forState:UIControlStateNormal];
    [locateBtn addTarget:self action:@selector(locate:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *locateBtnItem = [[[UIBarButtonItem alloc] initWithCustomView:locateBtn] autorelease];
    self.navigationItem.leftBarButtonItem = locateBtnItem;
    
    UIImage *filterBtnImage = [UIImage imageNamed:@"filter-btn.png"];
    UIButton *filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterBtn setFrame:CGRectMake(0.0f, 0.0f, filterBtnImage.size.width, filterBtnImage.size.height)];
    [filterBtn setImage:filterBtnImage forState:UIControlStateNormal];
    [filterBtn addTarget:self action:@selector(filter:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *filterBtnItem = [[[UIBarButtonItem alloc] initWithCustomView:filterBtn] autorelease];
    self.navigationItem.rightBarButtonItem = filterBtnItem;
    
    [self resetMapLocationWithAnimation:NO location:CLLocationCoordinate2DMake(-37.812225, 144.963055) zoom:2.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshView) 
                                                 name:kSyncCompleteNotificaton
                                               object:nil];
    
    [self.map.userLocation addObserver:self 
                                forKeyPath:@"location" 
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) 
                                   context:nil];
    
    self.filterViewController = [[[FilterViewController alloc] initWithNibName:@"FilterView" bundle:nil] autorelease];
    self.filterViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.filterViewController.delegate = self;

    [self refreshView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.map = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Methods - 

- (void)refreshView
{
    [self.map removeAnnotations:self.places];
    
    self.places = [Place filteredPlaces];
    for (Place *place in self.places) 
    {
        [self.map addAnnotation:place];
    }
}

- (void)locate:(id)sender 
{
    if (!self.map.showsUserLocation) 
    {
        self.map.showsUserLocation = YES;
    } 
    else 
    {
        if (self.map.userLocation && CLLocationCoordinate2DIsValid(self.map.userLocation.coordinate) && self.map.userLocation.coordinate.latitude != 0.0) {
            [self resetMapLocationWithAnimation:YES location:self.map.userLocation.coordinate zoom:0.2];
        }
    }
}

- (void)filter:(id)sender 
{
    [self presentViewController:self.filterViewController animated:YES completion:nil];
}

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

#pragma mark - Map view KVC - 

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{           
    [self resetMapLocationWithAnimation:YES location:self.map.userLocation.coordinate zoom:0.2]; 
    [self.map.userLocation removeObserver:self forKeyPath:@"location"];
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
            
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            annotationView.rightCalloutAccessoryView = rightButton;
        } 
        else 
        {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        
        UIImageView *thumbImageView = nil;
        if ([place.category.name isEqualToString:@"Toilets"]) {
            annotationView.pinColor = MKPinAnnotationColorGreen;
            thumbImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toilet-cell.png"]];
        } else {
            annotationView.pinColor = MKPinAnnotationColorRed;
            thumbImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[place imagePathForType:kPlaceImageTypeCell]]];

        }
    
        thumbImageView.frame = CGRectMake(0,0,30,30);
        annotationView.leftCalloutAccessoryView = thumbImageView;
        [thumbImageView release];
        
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
    if (_animatingToAnnotation) 
    {
        for (Place *place in self.places) 
        {
            if ([place.placeId intValue] == [self.selectedPlaceId intValue]) 
            {
                [self.map selectAnnotation:place animated:YES];
            }
        }
        
        _animatingToAnnotation = NO;
        self.selectedPlaceId = nil;
    }
}

#pragma mark - Filter view delegates -

- (void)filterChanged:(BOOL)didFilterChange
{
    if (didFilterChange) 
    {
        [self refreshView];   
    }
    
    [self.filterViewController dismissModalViewControllerAnimated:YES];
}

@end
