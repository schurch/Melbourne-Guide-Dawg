//
//  Site+Site_MapAnnotation.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 18/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Place+Extensions.h"
#import "NSManagedObjectContext+Extras.h"
#import "NSManagedObject+Entity.h"
#import "SyncManager.h"

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

+ (NSString *)applicationPhotosDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"photos"];
}

+ (Place *)createDummyPlaceWithImage:(NSString *)imageName lat:(double)lat lng:(double)lng category:(Category *)category
{
    Place *place = [self place];
    [place setCategory:category];
    
    static int placeId = 1;
    
    place.placeId = [NSNumber numberWithInt:placeId];
    place.name = @"VIC Nat Gallery";
    place.address = @"6 Warburton St, Brunswick, 3006";
    
//    NSString *tinyImageName = [NSString stringWithFormat:@"%@_tiny.jpg", imageName];
//    NSString *thumbImageName = [NSString stringWithFormat:@"%@_thumb.jpg", imageName];
    
//    NSData *imageTinyData = UIImagePNGRepresentation([UIImage imageNamed:tinyImageName]);
//    place.imageTinyData = imageTinyData;
    
    place.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse accumsan leo eu felis pharetra ut semper ipsum pellentesque. Sed sed erat ut mi ullamcorper auctor. Nunc faucibus volutpat metus. Suspendisse quis purus at sem laoreet fringilla rhoncus sed leo. Maecenas purus odio, suscipit ac rhoncus id, ultrices eget nisl. Pellentesque tempus nisl eget leo volutpat scelerisque. Nam pretium odio vel enim adipiscing sit amet tristique nisl ultricies. \r\n \r\nAenean et urna enim, a tincidunt dui. Curabitur rutrum ligula ut nisl viverra gravida ut et mauris. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Pellentesque suscipit lobortis auctor. Integer dignissim sem quis eros tempor et elementum leo fringilla. Duis pulvinar dictum neque, ut aliquet lacus porttitor malesuada. Vivamus sed arcu quis dolor elementum rhoncus. Nam aliquam semper diam, consequat faucibus erat varius sed. Nulla facilisi.";
    
    place.date = [NSDate date]; 
    place.lat = [NSNumber numberWithDouble:lat];
    place.lng = [NSNumber numberWithDouble:lng];
    
    placeId++;  
    
    return place;
}


+ (Place *)place
{
    return [self entityWithContext:[NSManagedObjectContext sharedInstance]];
}

+ (NSArray *)allPlaces 
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:[NSManagedObjectContext sharedInstance]];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    
    return [[NSManagedObjectContext sharedInstance] executeFetchRequest:request error:nil];
}

- (NSString *)imagePathForType:(PlaceImageType)imageType
{
    NSString *placePhotosDir = [self imagesDir];
    NSString *filename = [[self.imageFileName componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *extension = [[self.imageFileName componentsSeparatedByString:@"."] objectAtIndex:1];
    NSString *imageTypeString = [self imageTypeStringForType:imageType];
    NSString *fullFilename = [NSString stringWithFormat:@"%@_%@.%@", filename, imageTypeString, extension];
    
    return [NSString stringWithFormat:@"%@/%@", placePhotosDir, fullFilename];
}

- (NSString *)imageTypeStringForType:(PlaceImageType)imageType
{
    NSString *imageTypeString = nil;
    
    switch (imageType) {
        case kPlaceImageTypeCell:
            imageTypeString = @"cell";
            break;
        case kPlaceImageTypeSmall:
            imageTypeString = @"small";
            break;
        case kPlaceImageTypeNormal:
            imageTypeString = @"normal";
            break;
        case kPlaceImageTypeRetina:
            imageTypeString = @"retina";
            break;
        default:
            break;
    }
    
    return imageTypeString;
}

- (NSString *)imagesDir
{
    return [[Place applicationPhotosDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.placeId]];
}

@end
