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
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *text;

- (id)initWithData:(NSDictionary *)data;
- (NSString *)timeSinceText;

@end
