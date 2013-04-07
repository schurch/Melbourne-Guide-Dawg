//
//  MapViewController.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 16/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FilterViewController.h"

#define METERS_PER_MILE 1609.344

@interface MapViewController : UIViewController<MKMapViewDelegate, FilterProtocol>
{
    BOOL _animatingToAnnotation;
}

@property (nonatomic, strong) NSNumber *selectedPlaceId;
@property (nonatomic, strong) IBOutlet MKMapView *map;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *places;
@property (nonatomic, assign) CLLocationCoordinate2D location;

- (void)zoomToSite;
- (void)refreshView;

@end
