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

@interface MapViewController : UIViewController<FilterProtocol>

@property (nonatomic, strong) NSNumber *selectedPlaceId;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *places;
@property (nonatomic, assign) CLLocationCoordinate2D location;

- (void)refreshView;

@end
