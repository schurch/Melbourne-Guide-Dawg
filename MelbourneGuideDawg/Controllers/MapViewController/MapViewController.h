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

@property (nonatomic, retain) NSNumber *selectedPlaceId;
@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *places;
@property (nonatomic, assign) CLLocationCoordinate2D location;

- (void)zoomToSite;
- (void)refreshView;

@end
