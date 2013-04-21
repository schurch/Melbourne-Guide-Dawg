//
//  Comment.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 15/09/2012.
//
//

#import "Comment.h"
#import "NSString+ErrorChecking.h"

@implementation Comment

#pragma mark - init / dealloc

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];

    if (self) {
        self.commentID = [[data objectForKey:@"id"] intValue];
        self.name = [NSString validStringOrNil:[data objectForKey:@"commenter"]];
        self.text = [NSString validStringOrNil:[data objectForKey:@"body"]];
        self.posting = NO;

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";         //2012-09-14T09:17:26Z
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        NSString *dateString = [NSString validStringOrNil:[data objectForKey:@"created_at"]];
        self.date = [dateFormatter dateFromString:dateString];
    }
    
    return self;
}


#pragma mark - methods -

- (NSString *)timeSinceText
{
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit
                                               fromDate:self.date
                                                 toDate:[NSDate date]
                                                options:0];
    
    if (components.day > 0) {
        return [NSString stringWithFormat:@"%i days ago", components.day];
    } else if (components.hour > 0) {
        return [NSString stringWithFormat:@"%i hours ago", components.hour];
    } else {
        return [NSString stringWithFormat:@"%i minutes ago", components.minute];
    }
}

@end
