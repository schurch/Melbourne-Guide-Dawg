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
+ (NSURL *)applicationPhotosDir;
- (AFImageRequestOperation *)generateImageFetchOperationWithType:(NSString *)imageType placeId:(NSString *)placeId imageFileName:(NSString *)imageFileName imagePath:(NSString *)imagePath;
@end

@implementation SyncManager

+ (NSURL *)applicationPhotosDir
{
    NSString *documentsDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [NSString stringWithFormat:@"%@photos", documentsDir];
}

#pragma mark - Public methods -

- (void)syncWithCompletionBlock:(void (^)())completionBlock errorBlock:(void (^)(NSError *))errorBlock
{    
    NSURLRequest *categoryRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:CATEGORIES_URL]];
    AFJSONRequestOperation *categoryOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:categoryRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
    {
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
        
        //fetch places
        NSURLRequest *placesRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:PLACES_URL]];
        AFJSONRequestOperation *placesOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:placesRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
        {
            for (Place *place in [Place allPlaces]) {
                [[NSManagedObjectContext sharedInstance] deleteObject:place];
            }
            
            //save the deletes
            [[NSManagedObjectContext sharedInstance] save]; 
            
            for (int i = 0; i < [JSON count]; i++) {
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
                place.lat = [NSNumber numberWithInt:[lat intValue]];
                place.lng = [NSNumber numberWithInt:[lng intValue]];
                place.text = text;
                place.url = url;
                place.imageFileName = imageFileName;
                
                //fetch associted category
                Category *category = [Category categoryWithId:[NSNumber numberWithInt:[categoryId intValue]]];
                place.category = category;
                
                NSLog(@"Create place with: id = %@, category id = %@, name = %@, address = %@, lat = %@, lng = %@, image name = %@, text = %@, url = %@", placeId, categoryId, name, address, lat, lng, imageFileName, text, url);
                
                [[NSManagedObjectContext sharedInstance] save];  
                
                //make sure photo dir exists
                NSFileManager *fileManager = [NSFileManager defaultManager];

                NSString *photosDir = [NSString stringWithFormat:@"%@/%@/", [SyncManager applicationPhotosDir], placeId];
                NSLog(@"Place photos DIR: %@", photosDir);
                
                NSError *error;
                if (![fileManager createDirectoryAtPath:photosDir withIntermediateDirectories:YES attributes:nil error:&error]) 
                {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#if DEBUG
                    abort();
#endif
                }; 
                
                //download images
                NSMutableArray *imageDownloadOperations = [[NSMutableArray alloc] initWithCapacity:3];
                
                //retina image
                
                //normal
                AFImageRequestOperation *imageRequest = [self generateImageFetchOperationWithType:@"normal" placeId:placeId imageFileName:imageFileName imagePath:photosDir];
                [imageDownloadOperations addObject:imageRequest];
                
                //small image
                AFImageRequestOperation *smallImageRequest = [self generateImageFetchOperationWithType:@"small" placeId:placeId imageFileName:imageFileName imagePath:photosDir];
                [imageDownloadOperations addObject:smallImageRequest];
                
                //cell image
                AFImageRequestOperation *cellImageRequest = [self generateImageFetchOperationWithType:@"cell" placeId:placeId imageFileName:imageFileName imagePath:photosDir];
                [imageDownloadOperations addObject:cellImageRequest];
                
                AFHTTPClient *imageFetchClient = [[AFHTTPClient alloc] init];
                //report progress..
                [imageFetchClient enqueueBatchOfHTTPRequestOperations:imageDownloadOperations progressBlock:nil completionBlock:^(NSArray *operations)
                {
                    //if last image donwload, then complete
                    if (i == ([JSON count] - 1)) {
                         completionBlock();   
                    }
                }];
                
                [imageFetchClient release];
                [imageDownloadOperations release];
            }
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

- (AFImageRequestOperation *)generateImageFetchOperationWithType:(NSString *)imageType placeId:(NSString *)placeId imageFileName:(NSString *)imageFileName imagePath:(NSString *)imagePath
{
    NSString *cellImageUrl = [NSString stringWithFormat:@"%@/%@/%@/%@", BASE_IMAGE_URL, placeId, imageType, imageFileName];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:cellImageUrl]];
    AFImageRequestOperation *imageRequest = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest success:^(UIImage *image)
     {
         NSLog(@"Success downloading %@ image for place ID %@ ..", imageType, placeId);
         
         NSString *filename = [[imageFileName componentsSeparatedByString:@"."] objectAtIndex:0];
         NSString *newFileName = [NSString stringWithFormat:@"%@_%@.jpg", filename, imageType];
         
         NSString *imagePath = [NSString stringWithFormat:@"%@%@", imagePath, newFileName];
         
         NSLog(@"Saving image to %@.", imagePath);
         
         NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
         [imageData writeToFile:imagePath atomically:YES];
     }];
    
    return imageRequest;
}

@end
