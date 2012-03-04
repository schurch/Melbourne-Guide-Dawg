//
//  Site+Site_MapAnnotation.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 18/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"
#import <MapKit/MapKit.h>

@interface Place(Extensions) <MKAnnotation>

+ (void)addDummyData;
+ (Place *)place;
+ (NSArray *)allPlaces;
+ (void)savePlace:(Place *)place;
+ (void)deletePlace:(Place *)place;

@end
