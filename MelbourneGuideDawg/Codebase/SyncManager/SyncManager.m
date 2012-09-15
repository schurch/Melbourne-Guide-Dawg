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

#define CATEGORIES_PATH @"categories.json"
#define PLACES_PATH @"places.json"
#define BASE_IMAGE_URL @"http://s3.amazonaws.com/melbourne_guide_dawg/images"

@interface SyncManager()
- (AFImageRequestOperation *)generateImageFetchOperationWithType:(PlaceImageType)imageType place:(Place *)place;
- (void)syncFailedWithError:(NSError *)error andErrorBlock:(void (^)(NSError *))errorBlock;
- (void)syncSuccessWithCompletionBlock:(void (^)())completionBlock;
@end

@implementation SyncManager

#pragma mark - Init / Dealloc

- (id)init
{
    self = [super init];
    if (self) {
        _syncInProgress = NO;
    }
    
    return self;
}

- (void)dealloc
{
    
    [super dealloc];
}

#pragma mark - Public methods -

- (void)syncWithCompletionBlock:(void (^)())completionBlock errorBlock:(void (^)(NSError *))errorBlock progressBlock:(void (^)(NSString *))progressBlock
{    
    if (_syncInProgress) {
        return;
    }
    
    _syncInProgress = YES;
    
    NSString *categoriesURL = [NSString stringWithFormat:@"%@%@", kServerBaseURL, CATEGORIES_PATH];
    NSURLRequest *categoryRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:categoriesURL]];
    AFJSONRequestOperation *categoryOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:categoryRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
    {
        progressBlock(@"Downloading categories..");
        
        for (Place *place in [Place allPlaces]) {
            [[NSManagedObjectContext sharedInstance] deleteObject:place];
        }
        
        [[NSManagedObjectContext sharedInstance] save]; 
        
        for (Category *category in [Category allCategories]) {
            [[NSManagedObjectContext sharedInstance] deleteObject:category];
        }
        
        [[NSManagedObjectContext sharedInstance] save];  
        
        for (NSDictionary *downloadedCategory in JSON) {
            NSString *categoryId = [downloadedCategory valueForKey:@"id"];
            NSString *categoryName = [downloadedCategory valueForKey:@"name"];
            
            NSLog(@"Downloaded category with: id = %@, name = %@", categoryId, categoryName);
            
            Category *category = [Category category];
            category.categoryId = [NSNumber numberWithInt:[categoryId intValue]];
            category.name = categoryName;       
            
            if ([category.name isEqualToString:@"Toilets"]) {
                category.filterSelected = [NSNumber numberWithBool:NO];                
            } else {
                category.filterSelected = [NSNumber numberWithBool:YES];
            }
        }

        [[NSManagedObjectContext sharedInstance] save];  
        
        
        progressBlock(@"Downloading places..");
        
        NSString *placesURL = [NSString stringWithFormat:@"%@%@", kServerBaseURL, PLACES_PATH];
        NSURLRequest *placesRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:placesURL]];
        AFJSONRequestOperation *placesOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:placesRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
        {            
            
            for (int i = 0; i < [JSON count]; i++) {
                
//                progressBlock([NSString stringWithFormat:@"Downloading places..", i + 1, [JSON count]]);
                
                NSDictionary *downloadedPlace = [JSON objectAtIndex:i];
                
                //validate returned data
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
                place.url = [url isKindOfClass:[NSNull class]] ? nil : url;
                place.imageFileName = [imageFileName isKindOfClass:[NSNull class]] ? nil : imageFileName;
                
                //fetch associted category
                Category *category = [Category categoryWithId:[NSNumber numberWithInt:[categoryId intValue]]];
                place.category = category;
                
                NSLog(@"Create place with: id = %@, category id = %@, name = %@, address = %@, lat = %@, lng = %@, image name = %@, text = %@, url = %@", placeId, categoryId, name, address, lat, lng, imageFileName, text, url);
                
                [[NSManagedObjectContext sharedInstance] save];  
            }
            
            progressBlock(@"Downloading images..");
            
            NSMutableArray *imageDownloadOperations = [[NSMutableArray alloc] initWithCapacity:3];
            
            NSArray *places = [Place allPlaces];
            for (Place *place in places) {    
                if (!place.imageFileName) {
                    continue;
                }
                
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

            AFHTTPClient *imageFetchClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_IMAGE_URL]];
            //report progress..
            [imageFetchClient enqueueBatchOfHTTPRequestOperations:imageDownloadOperations progressBlock:^(NSUInteger numberOfCompletedOperations, NSUInteger totalNumberOfOperations) {
//                progressBlock([NSString stringWithFormat:@"Downloading image %i of %i..", numberOfCompletedOperations, totalNumberOfOperations]);
            } completionBlock:^(NSArray *operations) {
                [self syncSuccessWithCompletionBlock:completionBlock];  
            }];
            
            
            [imageDownloadOperations release];
            [imageFetchClient release];

            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            [self syncFailedWithError:error andErrorBlock:errorBlock];
        }];   
        
        [placesOperation start];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self syncFailedWithError:error andErrorBlock:errorBlock];
    }];
    
    [categoryOperation start];
}

#pragma mark - Private methods -

- (void)syncFailedWithError:(NSError *)error andErrorBlock:(void (^)(NSError *))errorBlock
{
    _syncInProgress = NO;
    
    NSNotification *failNotification = [NSNotification notificationWithName: kSyncFailedNotificaton object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:failNotification];
    
    errorBlock(error);
}

- (void)syncSuccessWithCompletionBlock:(void (^)())completionBlock 
{
    _syncInProgress = NO;
    
    NSNotification *successNotification = [NSNotification notificationWithName: kSyncCompleteNotificaton object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:successNotification];
    
    completionBlock();
}

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
        if (![fileManager createDirectoryAtURL:[place imagesDir] withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"Unresolved error creating place photos dir %@, %@", error, [error userInfo]);
#if DEBUG
            abort();
#endif
        }; 
        
        NSURL *imagePath = [place imagePathForType:imageType];
        [Utils excludeURLPathFromBackup:imagePath];
        
        NSLog(@"Saving image to %@.", imagePath);       
        NSData *imageData = UIImagePNGRepresentation(image);
        BOOL didWriteSuccessfully = [imageData writeToURL:imagePath atomically:YES];
        if (!didWriteSuccessfully) {
#if DEBUG
            abort();
#endif
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Unresolved error fetching image for place %@, %@", error, [error userInfo]);
    }];
    
    return imageRequest;
}

@end
