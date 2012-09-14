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
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Category.h"

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

+ (NSURL *)applicationPhotosDir
{
    NSURL *URL = [[Utils downloadDirectory] URLByAppendingPathComponent:@"photos"];
    [Utils excludeURLPathFromBackup:URL];
    return URL;
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

+ (void)submitWithDetails:(NSDictionary *)details image:(UIImage *)image success:(void (^)())success failure:(void (^)(NSString *error))failure
{
    AFHTTPClient *client = [[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.melbourneguidedawg.com"]] autorelease];
    [client setAuthorizationHeaderWithUsername:kUploadUsername password:kUploadPassword];
    client.parameterEncoding = AFJSONParameterEncoding;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"/places.json" parameters:details constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"place[image]" fileName:@"image.png" mimeType:@"image/png"];
    }];
    
    AFHTTPRequestOperation *operation = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Response object: %@", responseObject);
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error submmitting location: %@", error.localizedDescription);
        failure(@"There was an error submitting the place.");
    }];
    
    [operation start];
}

#pragma mark - Methods -

- (NSURL *)imagePathForType:(PlaceImageType)imageType
{
    NSURL *placePhotosDir = [self imagesDir];

    NSString *filename = [[self.imageFileName componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *extension = [[self.imageFileName componentsSeparatedByString:@"."] objectAtIndex:1];
    NSString *imageTypeString = [self imageTypeStringForType:imageType];
    NSString *fullFilename = [NSString stringWithFormat:@"%@_%@.%@", filename, imageTypeString, extension];
    
    return [placePhotosDir URLByAppendingPathComponent:fullFilename];
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

- (NSURL *)imagesDir
{
    return [[Place applicationPhotosDir] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.placeId]];
}

@end
