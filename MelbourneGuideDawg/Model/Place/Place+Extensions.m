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

+ (Place *)place
{
    return [self entityWithContext:[NSManagedObjectContext sharedInstance]];
}

+ (NSArray *)filteredPlaces
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:[NSManagedObjectContext sharedInstance]];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category.filterSelected == %@", [NSNumber numberWithBool:YES]];
    [request setPredicate:predicate];   
    
    NSError *error = nil;
    NSArray *results = [[NSManagedObjectContext sharedInstance] executeFetchRequest:request error:&error];
    
    if (error) {
        NSLog(@"Error occured while fetching filtered places: %@", error);
    }
    
    return results;
}

+ (NSArray *)allPlaces 
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:[NSManagedObjectContext sharedInstance]];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return [[NSManagedObjectContext sharedInstance] executeFetchRequest:request error:nil];
}

#pragma mark - Methods -

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
