//
//  PlaceDetailFetcher.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 13/09/2012.
//
//

#import "PlaceDetailFetcher.h"
#import "AFNetworking.h"
#import "Comment.h"

@implementation PlaceDetailFetcher

static NSString *kFetchDetailsPath = @"places/%i/details?device_id=%@";
static NSString *kLikePlacePath = @"places/%i/like?device_id=%@";
static NSString *kUnlikePlacePath = @"places/%i/unlike?device_id=%@";
static NSString *kCommentsPath = @"places/%i/comments.json";
static NSString *kPostCommentPath = @"places/%i/comments";

#pragma mark - general fetch -

+ (void)fetchPlaceDetailsForPlaceID:(int)ID success:(void (^)(int likeCount, int commentCount, BOOL isLiked))success failure:(void (^)(NSString *error))failure
{
    NSString *fullURL = [NSString stringWithFormat:@"%@%@", kServerBaseURL, kFetchDetailsPath];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:fullURL, ID, [Utils deviceID]]]];
    
    AFJSONRequestOperation *detailsOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
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

#pragma mark - likes -

+ (void)likePlaceWithID:(int)ID success:(void (^)())success failure:(void (^)(NSString *error))failure
{
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kServerBaseURL]];
    
    NSString *path = [NSString stringWithFormat:kLikePlacePath, ID, [Utils deviceID]];
    [client postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully liked place with ID %i", ID);
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR :: PlaceFetcher :: LikePlace :: %@", [error localizedDescription]);
        failure(@"There was a problem liking the place.");
    }];
}

+ (void)unlikePlaceWithID:(int)ID success:(void (^)())success failure:(void (^)(NSString *error))failure
{
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kServerBaseURL]];
    
    NSString *path = [NSString stringWithFormat:kUnlikePlacePath, ID, [Utils deviceID]];
    [client postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully unliked place with ID %i", ID);
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR :: PlaceFetcher :: UnlikePlace :: %@", [error localizedDescription]);
        failure(@"There was a problem liking the place.");
    }];
}

#pragma mark - commments -

+ (void)postCommentForPlaceID:(int)ID withComment:(NSString *)comment success:(void (^)())success failure:(void (^)(NSString *error))failure
{
    NSDictionary *details =
    @{
        @"comment[device_id]" : [Utils deviceID],
        @"comment[commenter]" : @"stefanchurch",
        @"comment[body]" : comment
    };
    
    AFHTTPClient *client = [[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kServerBaseURL]] autorelease];
    
    [client postPath:kCommentsPath parameters:details success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(@"There was a problem posting the comment.");
    }];
}

+ (void)fetchCommentsForPlaceID:(int)ID success:(void (^)(NSArray *comments))success failure:(void (^)(NSString *error))failure
{
    NSString *fullURL = [NSString stringWithFormat:@"%@%@", kServerBaseURL, kCommentsPath];
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:fullURL, ID]]];
    
    AFJSONRequestOperation *detailsOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSLog(@"Successfully fetched place comments");
        
        NSMutableArray *comments = [NSMutableArray array];
        for (NSDictionary *commentData in JSON) {
            Comment *comment = [[[Comment alloc] initWithData:commentData] autorelease];
            [comments addObject:comment];
        }
        
        success(comments);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"ERROR :: PlaceFetcher :: fetchCommentsForPlaceID :: %@", error.localizedDescription);
        failure(@"There was a problem fetching the comments.");
    }];
    
    [detailsOperation start];
}

@end
