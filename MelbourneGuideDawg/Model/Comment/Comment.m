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
        self.commentID = [[NSString validStringOrNil:[data objectForKey:@"id"]] intValue];
        self.name = [NSString validStringOrNil:[data objectForKey:@"commenter"]];
        self.text = [NSString validStringOrNil:[data objectForKey:@"body"]];

        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";         //2012-09-14T09:17:26Z
        NSString *dateString = [NSString validStringOrNil:[data objectForKey:@"created"]];
        self.date = [dateFormatter dateFromString:dateString];
    }
    
    return self;
}

- (void)dealloc
{
    [_name release];
    [_date release];
    [_text release];
    [super dealloc];
}

#pragma mark - methods -

- (NSString *)timeSinceText
{
    
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
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
