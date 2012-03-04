//
//  Site+Site_MapAnnotation.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 18/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place+Extensions.h"

@implementation Place(Extensions)

#pragma mark - Map annotation delegates -

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
    return self.address;
}

#pragma mark - Class methods -

+ (void)addDummyPlaceWithImage:(NSString *)imageName lat:(double)lat lng:(double)lng 
{
    Place *place = [self place];
    
    static int placeId = 1;
    
    place.placeId = [NSNumber numberWithInt:placeId];
    place.name = @"VIC Nat Gallery";
    place.address = @"6 Warburton St, Brunswick, 3006";
    
    NSString *tinyImageName = [NSString stringWithFormat:@"%@_tiny.jpg", imageName];
    NSString *thumbImageName = [NSString stringWithFormat:@"%@_thumb.jpg", imageName];
    
    NSData *imageTinyData = UIImagePNGRepresentation([UIImage imageNamed:tinyImageName]);
    place.imageTinyData = imageTinyData;
    
    place.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse accumsan leo eu felis pharetra ut semper ipsum pellentesque. Sed sed erat ut mi ullamcorper auctor. Nunc faucibus volutpat metus. Suspendisse quis purus at sem laoreet fringilla rhoncus sed leo. Maecenas purus odio, suscipit ac rhoncus id, ultrices eget nisl. Pellentesque tempus nisl eget leo volutpat scelerisque. Nam pretium odio vel enim adipiscing sit amet tristique nisl ultricies. \r\n \r\nAenean et urna enim, a tincidunt dui. Curabitur rutrum ligula ut nisl viverra gravida ut et mauris. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Pellentesque suscipit lobortis auctor. Integer dignissim sem quis eros tempor et elementum leo fringilla. Duis pulvinar dictum neque, ut aliquet lacus porttitor malesuada. Vivamus sed arcu quis dolor elementum rhoncus. Nam aliquam semper diam, consequat faucibus erat varius sed. Nulla facilisi.";
    
    place.date = [NSDate date]; 
    place.lat = [NSNumber numberWithDouble:lat];
    place.lng = [NSNumber numberWithDouble:lng];
    
    [self savePlace:place];
    
    placeId++;   
}

+ (void)addDummyData
{
    for (int i = 0; i < 10; i++) 
    {
        [self addDummyPlaceWithImage:@"melbourne1" lat:-37.812225 lng:144.963055];
        [self addDummyPlaceWithImage:@"melbourne2" lat:-37.80490 lng:144.97121];    
        [self addDummyPlaceWithImage:@"melbourne3" lat:-37.82036 lng:144.94477];    
        [self addDummyPlaceWithImage:@"melbourne4" lat:-37.81290 lng:144.95190];    
        [self addDummyPlaceWithImage:@"melbourne5" lat:-37.81507 lng:144.97396];    
        [self addDummyPlaceWithImage:@"melbourne6" lat:-37.82423 lng:144.96958];    
        [self addDummyPlaceWithImage:@"melbourne7" lat:-37.81941 lng:144.97516];    
        [self addDummyPlaceWithImage:@"melbourne8" lat:-37.81575 lng:144.96263];  
    }   
}

+ (Place *)place
{
    NSManagedObjectContext *context = [NSManagedObjectContext sharedInstance];
    return [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];   
}

+ (NSArray *)allPlaces 
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:[NSManagedObjectContext sharedInstance]];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    
    //    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"objectId" ascending:YES] autorelease];
    //    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return [[NSManagedObjectContext sharedInstance] executeFetchRequest:request error:nil];
}

+ (void)savePlace:(Place *)place
{
    [[NSManagedObjectContext sharedInstance] insertObject:place];
    [[NSManagedObjectContext sharedInstance] save:nil];   
}

+ (void)deletePlace:(Place *)place
{
    [[NSManagedObjectContext sharedInstance] deleteObject:place];
    [[NSManagedObjectContext sharedInstance] save:nil];
}

@end
