//
//  Site+Site_MapAnnotation.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 18/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place+Extensions.h"

@implementation Place(Extensions)

- (CLLocationCoordinate2D)coordinate 
{
    CLLocationCoordinate2D coords;
    coords.latitude = [self.lat doubleValue];
    coords.longitude = [self.lng doubleValue];
    return coords;
}

- (NSString *)title 
{
    return self.name;
}

- (NSString *)subtitle 
{
    return self.location;
}

@end
