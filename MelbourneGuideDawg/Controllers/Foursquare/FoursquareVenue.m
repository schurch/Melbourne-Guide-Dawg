//
//  FoursquareVenue.m
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 24/03/2013.
//
//

#import "FoursquareVenue.h"

@implementation FoursquareVenue

#pragma mark - init / dealloc

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        self.foursquareId = dictionary[@"id"];
        self.name = dictionary[@"name"];
        
        if ([dictionary[@"url"] length] > 0) {
            self.venueURL = [NSURL URLWithString:dictionary[@"url"]];
        }
        
        if ([dictionary[@"location"] count] > 0) {
            self.address = dictionary[@"location"][@"address"];
            self.city = dictionary[@"location"][@"city"];
            self.country = dictionary[@"location"][@"country"];
            self.postCode = dictionary[@"location"][@"postalCode"];
            self.state = dictionary[@"location"][@"state"];
            self.locationCoords = CLLocationCoordinate2DMake([dictionary[@"location"][@"lat"] doubleValue], [dictionary[@"location"][@"lng"] doubleValue]);
        }
    }
    
    return self;
}


#pragma mark - methods -

- (NSString *)fullAddress
{
    NSMutableString *address = [[NSMutableString alloc] init];
    
    if (self.address) {
        [address appendFormat:@"%@, ", self.address];
    }
    
    if (self.city) {
        [address appendFormat:@"%@, ", self.city];
    }
    
    if (self.state) {
        [address appendFormat:@"%@, ", self.state];
    }
    
    if (self.postCode) {
        [address appendFormat:@"%@, ", self.postCode];
    }
    
    if (self.country) {
        [address appendFormat:@"%@, ", self.country];
    }
    
    if ([[address substringFromIndex:([address length] - 2)] isEqualToString:@", "]) {
        return [address substringToIndex:([address length] - 2)];
    } else {
        return address;
    }
}

@end
