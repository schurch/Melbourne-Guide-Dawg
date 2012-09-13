//
//  PlaceDetailFetcher.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 13/09/2012.
//
//

#import "PlaceDetailFetcher.h"
#import "AFNetworking.h"

@implementation PlaceDetailFetcher

static NSString *kHostURL = @"http://www.melbourneguidedawg.com/";
static NSString *kFetchDetailsPath = @"places/%i/likes?device_id=%@";
static NSString *kLikePlacePath = @"places/%i/like?device_id=%@";
static NSString *kUnlikePlacePath = @"places/%i/unlike?device_id=%@";

- (void)fetchPlaceDetailsForPlaceID:(int)ID success:(void (^)(int likeCount, int commentCount, BOOL isLiked))success failure:(void (^)(NSString *error))failure
{
    NSString *fullURL = [NSString stringWithFormat:@"%@%@", kHostURL, kFetchDetailsPath];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:fullURL, ID, [Utils deviceID]]]];
    
    AFJSONRequestOperation *detailsOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        NSLog(@"Successfully fetched place details");
        int likeCount = [[JSON objectForKey:@"count"] intValue];
        BOOL isLiked = [[JSON objectForKey:@"have_liked"] boolValue];
        success(likeCount, 0, isLiked);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"ERROR :: PlaceFetcher :: FetchPlaceDetails :: %@", error.localizedDescription);
        failure(@"Could not fetch place details.");
    }];
    
    [detailsOperation start];
}

- (void)likePlaceWithID:(int)ID success:(void (^)())success failure:(void (^)(NSString *error))failure
{
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kHostURL]];
    
    NSString *path = [NSString stringWithFormat:kLikePlacePath, ID, [Utils deviceID]];
    [client postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully liked place with ID %i", ID);
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR :: PlaceFetcher :: LikePlace :: %@", [error localizedDescription]);
        failure(@"There was a problem liking the place.");
    }];
}

- (void)unlikePlaceWithID:(int)ID success:(void (^)())success failure:(void (^)(NSString *error))failure
{
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kHostURL]];
    
    NSString *path = [NSString stringWithFormat:kUnlikePlacePath, ID, [Utils deviceID]];
    [client postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully unliked place with ID %i", ID);
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR :: PlaceFetcher :: UnlikePlace :: %@", [error localizedDescription]);
        failure(@"There was a problem liking the place.");
    }];
}

@end
