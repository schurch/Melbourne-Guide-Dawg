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

+ (Place *)createDummyPlaceWithImage:(NSString *)imageName lat:(double)lat lng:(double)lng category:(Category *)category;

+ (Place *)place;
+ (NSArray *)allPlaces;

@end
