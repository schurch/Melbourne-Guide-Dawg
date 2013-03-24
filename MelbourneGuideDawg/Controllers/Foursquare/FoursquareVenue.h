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

@property (nonatomic, retain) NSString *foursquareId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSURL *venueURL;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSString *postCode;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, assign) CLLocationCoordinate2D locationCoords;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (NSString *)fullAddress;

@end
