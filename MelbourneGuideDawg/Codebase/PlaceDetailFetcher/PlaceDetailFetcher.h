//
//  PlaceDetailFetcher.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 13/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface PlaceDetailFetcher : NSObject

//general fetch
+ (void)fetchPlaceDetailsForPlaceID:(int)ID success:(void (^)(int likeCount, int commentCount, BOOL isLiked))success failure:(void (^)(NSString *error))failure;

//likes
+ (void)likePlaceWithID:(int)ID success:(void (^)())success failure:(void (^)(NSString *error))failure;
+ (void)unlikePlaceWithID:(int)ID success:(void (^)())success failure:(void (^)(NSString *error))failure;

//coments
+ (void)postCommentForPlaceID:(int)ID withComment:(NSString *)comment success:(void (^)(NSArray *comments))success failure:(void (^)(NSString *error))failure;
+ (void)fetchCommentsForPlaceID:(int)ID success:(void (^)(NSArray *comments))success failure:(void (^)(NSString *error))failure;

@end
