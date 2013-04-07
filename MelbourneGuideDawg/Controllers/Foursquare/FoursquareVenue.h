//
//  FoursquareVenue.h
//  MelbourneGuideDawg
//
//  Created by Stefan Church on 24/03/2013.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface FoursquareVenue : NSObject

@property (nonatomic, strong) NSString *foursquareId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSURL *venueURL;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *postCode;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, assign) CLLocationCoordinate2D locationCoords;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (NSString *)fullAddress;

@end
