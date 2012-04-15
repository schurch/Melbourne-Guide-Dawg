//
//  SyncManager.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 09/04/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncManager.h"
#import "AFNetworking.h"
#import "Place.h"
#import "Category.h"
#import "Place+Extensions.h"
#import "Category+Extensions.h"

#define CATEGORIES_URL @"http://www.melbourneguidedawg.com/categories.json"
#define PLACES_URL @"http://www.melbourneguidedawg.com/places.json"
#define BASE_IMAGE_URL @"http://s3.amazonaws.com/melbourne_guide_dawg/images"

@interface SyncManager()
- (AFImageRequestOperation *)generateImageFetchOperationWithType:(PlaceImageType)imageType place:(Place *)place;
@end

@implementation SyncManager

#pragma mark - Public methods -

- (void)syncWithCompletionBlock:(void (^)())completionBlock errorBlock:(void (^)(NSError *))errorBlock progressBlock:(void (^)(NSString *))progressBlock
{    
    NSURLRequest *categoryRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:CATEGORIES_URL]];
    AFJSONRequestOperation *categoryOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:categoryRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
    {
        progressBlock(@"Downloading categories..");
        
        for (Place *place in [Place allPlaces]) {
            [[NSManagedObjectContext sharedInstance] deleteObject:place];
        }
        
        //save the deletes
        [[NSManagedObjectContext sharedInstance] save]; 
        
        for (Category *category in [Category allCategories]) {
            [[NSManagedObjectContext sharedInstance] deleteObject:category];
        }
        
        //save the deletes
        [[NSManagedObjectContext sharedInstance] save];  
        
        for (NSDictionary *downloadedCategory in JSON) {
            NSString *categoryId = [downloadedCategory valueForKey:@"id"];
            NSString *categoryName = [downloadedCategory valueForKey:@"name"];
            
            NSLog(@"Downloaded category with: id = %@, name = %@", categoryId, categoryName);
            
            Category *category = [Category category];
            category.categoryId = [NSNumber numberWithInt:[categoryId intValue]];
            category.name = categoryName;            
        }

        //save the inserts
        [[NSManagedObjectContext sharedInstance] save];  
        
        NSURLRequest *placesRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:PLACES_URL]];
        AFJSONRequestOperation *placesOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:placesRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
        {            
            
            for (int i = 0; i < [JSON count]; i++) {
                
                progressBlock([NSString stringWithFormat:@"Downloading place %i of %i..", i + 1, [JSON count]]);
                
                NSDictionary *downloadedPlace = [JSON objectAtIndex:i];
                
                NSString *placeId = [downloadedPlace valueForKey:@"id"];
                NSString *categoryId = [downloadedPlace valueForKey:@"category_id"];
                NSString *name = [downloadedPlace valueForKey:@"name"];
                NSString *address = [downloadedPlace valueForKey:@"address"];
                NSString *lat = [downloadedPlace valueForKey:@"lat"];
                NSString *lng = [downloadedPlace valueForKey:@"lng"];
                NSString *imageFileName = [downloadedPlace valueForKey:@"image_file_name"];
                NSString *text = [downloadedPlace valueForKey:@"text"];
                NSString *url = [downloadedPlace valueForKey:@"url"];
                
                Place *place = [Place place];
                place.placeId = [NSNumber numberWithInt:[placeId intValue]];
                place.name = name;            
                place.address = address;
                place.lat = [NSNumber numberWithDouble:[lat doubleValue]];
                place.lng = [NSNumber numberWithDouble:[lng doubleValue]];
                place.text = text;
                place.url = url;
                place.imageFileName = imageFileName;
                
                //fetch associted category
                Category *category = [Category categoryWithId:[NSNumber numberWithInt:[categoryId intValue]]];
                place.category = category;
                
                NSLog(@"Create place with: id = %@, category id = %@, name = %@, address = %@, lat = %@, lng = %@, image name = %@, text = %@, url = %@", placeId, categoryId, name, address, lat, lng, imageFileName, text, url);
                
                [[NSManagedObjectContext sharedInstance] save];  
            }
            
            NSMutableArray *imageDownloadOperations = [[NSMutableArray alloc] initWithCapacity:3];
            
            NSArray *places = [Place allPlaces];
            for (Place *place in places) {                
                //retina image
                
                //normal image
                AFImageRequestOperation *imageRequest = [self generateImageFetchOperationWithType:kPlaceImageTypeNormal place:place];
                [imageDownloadOperations addObject:imageRequest];
                
                //small image
                AFImageRequestOperation *smallImageRequest = [self generateImageFetchOperationWithType:kPlaceImageTypeSmall place:place];
                [imageDownloadOperations addObject:smallImageRequest];
                
                //cell image
                AFImageRequestOperation *cellImageRequest = [self generateImageFetchOperationWithType:kPlaceImageTypeCell place:place];
                [imageDownloadOperations addObject:cellImageRequest];   
            }

            AFHTTPClient *imageFetchClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_IMAGE_URL ]];
            //report progress..
            [imageFetchClient enqueueBatchOfHTTPRequestOperations:imageDownloadOperations progressBlock:^(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations) {
                progressBlock([NSString stringWithFormat:@"Downloading image %i of %i..", numberOfCompletedOperations, totalNumberOfOperations]);
            } completionBlock:^(NSArray *operations) {
                    completionBlock();   
            }];
            
            
            [imageDownloadOperations release];
            [imageFetchClient release];

            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             errorBlock(error);
        }];   
        
        [placesOperation start];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        errorBlock(error);
    }];
    
    [categoryOperation start];
}

#pragma mark - Private methods -

- (AFImageRequestOperation *)generateImageFetchOperationWithType:(PlaceImageType)imageType place:(Place *)place
{
    NSString *placeId = [NSString stringWithFormat:@"%@", place.placeId];
    NSString *imageURL = [NSString stringWithFormat:@"%@/%@/%@/%@", BASE_IMAGE_URL, placeId, [place imageTypeStringForType:imageType], place.imageFileName];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]];
    
    AFImageRequestOperation *imageRequest = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest imageProcessingBlock:nil cacheName:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NSLog(@"Success downloading %@ image for place ID %@ ..", [place imageTypeStringForType:imageType], placeId);
        
        //make sure photos place dir exsists
        NSFileManager *fileManager = [NSFileManager defaultManager];        
        NSError *error;
        if (![fileManager createDirectoryAtPath:[place imagesDir] withIntermediateDirectories:YES attributes:nil error:&error]) 
        {
            NSLog(@"Unresolved error creating place photos dir %@, %@", error, [error userInfo]);
#if DEBUG
            abort();
#endif
        }; 
        
        NSString *imagePath = [place imagePathForType:imageType];
        
        NSLog(@"Saving image to %@.", imagePath);       
        NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
        BOOL didWriteSuccessfully = [imageData writeToFile:imagePath atomically:YES];
        if (!didWriteSuccessfully) {
            abort();
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Unresolved error fetching image for place %@, %@", error, [error userInfo]);
    }];
    
    return imageRequest;
}

@end
