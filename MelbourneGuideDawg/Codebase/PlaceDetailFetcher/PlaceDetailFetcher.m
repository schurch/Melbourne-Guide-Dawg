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

@interface PlaceDetailFetcher()
+ (NSArray *)generateCommmentsFromResponse:(id)responseJSON;
@end


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
        int likeCount = [[JSON objectForKey:@"like_count"] intValue];
        int commentCount = [[JSON objectForKey:@"comment_count"] intValue];
        BOOL isLiked = [[JSON objectForKey:@"have_liked"] boolValue];
        success(likeCount, commentCount, isLiked);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR :: PlaceFetcher :: fetchPlaceDetailsForPlaceID :: %@", error.localizedDescription);
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
        NSLog(@"ERROR :: PlaceFetcher :: likePlaceWithID :: %@", [error localizedDescription]);
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
        NSLog(@"ERROR :: PlaceFetcher :: unlikePlaceWithID :: %@", [error localizedDescription]);
        failure(@"There was a problem unliking the place.");
    }];
}

#pragma mark - commments -

+ (void)postCommentForPlaceID:(int)ID withComment:(NSString *)comment success:(void (^)(NSArray *comments))success failure:(void (^)(NSString *error))failure
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:kNameKeyLookup];
    if (!username || [username stringByRemovingNewLinesAndWhitespace].length == 0) {
        username = kDefaultCommentUsername;
    }
    
    NSDictionary *details =
    @{
        @"comment[device_id]" : [Utils deviceID],
        @"comment[commenter]" : username,
        @"comment[body]" : comment,
        @"comment[place_id]" : [NSNumber numberWithInt:ID]
    };
    
    AFHTTPClient *client = [[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kServerBaseURL]] autorelease];
    [client setParameterEncoding:AFJSONParameterEncoding];
    [client setAuthorizationHeaderWithUsername:kUploadUsername password:kUploadPassword];
    
    NSString *postPath = [NSString stringWithFormat:kCommentsPath, ID];
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:postPath parameters:details constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
    }];
    
    AFHTTPRequestOperation *operation = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully posted comment.");
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSArray *comments = [self generateCommmentsFromResponse:[responseString JSONValue]];
        success(comments);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR :: PlaceFetcher :: postCommentForPlaceID :: %@", error.localizedDescription);
        failure(@"There was a problem posting the comment.");
    }];
    
    [operation start];
}

+ (void)fetchCommentsForPlaceID:(int)ID success:(void (^)(NSArray *comments))success failure:(void (^)(NSString *error))failure
{
    AFHTTPClient *client = [[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kServerBaseURL]] autorelease];
    [client setParameterEncoding:AFJSONParameterEncoding];
    [client setAuthorizationHeaderWithUsername:kUploadUsername password:kUploadPassword];
    NSString *commentsPath = [NSString stringWithFormat:kCommentsPath, ID];
    NSMutableURLRequest *requestURL = [client requestWithMethod:@"GET" path:commentsPath parameters:nil];
    
    AFJSONRequestOperation *detailsOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestURL success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSLog(@"Successfully fetched place comments");
        NSArray *comments = [self generateCommmentsFromResponse:JSON];
        success(comments);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"ERROR :: PlaceFetcher :: fetchCommentsForPlaceID :: %@", error.localizedDescription);
        failure(@"There was a problem fetching the comments.");
    }];
    
    [detailsOperation start];
}

#pragma mark - private methods -

+ (NSArray *)generateCommmentsFromResponse:(id)responseJSON
{
    NSMutableArray *comments = [NSMutableArray array];
    for (NSDictionary *commentData in responseJSON) {
        Comment *comment = [[[Comment alloc] initWithData:commentData] autorelease];
        [comments addObject:comment];
    }
    
    return comments;
}

@end
