//
//  Site+Site_MapAnnotation.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 18/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place.h"
#import <MapKit/MapKit.h>


typedef enum {
    kPlaceImageTypeCell,
    kPlaceImageTypeSmall,
    kPlaceImageTypeNormal,
    kPlaceImageTypeRetina
} PlaceImageType;


@interface Place(Extensions) <MKAnnotation>

+ (NSString *)applicationPhotosDir;
+ (Place *)place;
+ (NSArray *)filteredPlaces;
+ (NSArray *)allPlaces;

- (NSString *)imageTypeStringForType:(PlaceImageType)imageType;
- (NSString *)imagePathForType:(PlaceImageType)imageType;
- (NSString *)imagesDir;

@end
