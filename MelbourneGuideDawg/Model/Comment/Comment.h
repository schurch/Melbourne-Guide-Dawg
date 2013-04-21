//
//  Comment.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 15/09/2012.
//
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (nonatomic, assign) BOOL posting;
@property (nonatomic, assign) int commentID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *text;

- (id)initWithData:(NSDictionary *)data;
- (NSString *)timeSinceText;

@end
