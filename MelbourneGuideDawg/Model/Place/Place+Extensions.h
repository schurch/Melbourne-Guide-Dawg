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

+ (NSURL *)applicationPhotosDir;
+ (Place *)place;
+ (NSArray *)filteredPlaces;
+ (NSArray *)allPlaces;
+ (void)submitWithDetails:(NSDictionary *)details image:(UIImage *)image success:(void (^)())success failure:(void (^)(NSString *error))failure;

- (NSString *)imageTypeStringForType:(PlaceImageType)imageType;
- (NSURL *)imagePathForType:(PlaceImageType)imageType;
- (NSURL *)imagesDir;

@end
